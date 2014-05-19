require 'pathname'
require 'thor'

class TMBundle < Thor
  desc 'edit PARTIAL_NAME', 'Edit an installed bundle (name will be matched against PARTIAL_NAME)'
  def edit partial_name
    matches = installed_bundles.select do |bundle|
      bundle.name =~ /^#{partial_name}/i
    end

    if matches.size > 1
      puts "please be more specific:"
      matches.each_with_index {|m,i| puts " #{i+1}) #{m.name}"}
      return false
    end

    if matches.empty?
      puts "nothing found"
      return false
    end

    bundle = matches.first
    mate bundle.path
  end

  desc 'update', 'Update installed bundles'
  def update
    require 'thread'
    signals = Queue.new
    trap('INT') { signals << :int }

    updated = []
    skipped = []
    errored = []

    installed_bundles[0..4].each do |bundle|
      within bundle do
        if not(File.exist?('./.git'))
          puts "------> Skipping #{bundle.name} (not a Git repo, delta bundle?)"
          skipped << bundle
          next
        end

        puts "------> Updating #{bundle.name}..."
        system(*%w[git pull --ff-only])
        success = $? == 0
        updated << bundle if success
        errored << bundle unless success
        puts
        (puts 'Exiting…'; exit) if signals.pop == :int until signals.empty?
      end
    end

    puts
    puts
    puts '------> Summary'
    puts
    puts "Skipped (#{skipped.size})\n- #{skipped.map(&:name).join("\n- ")}\n\n" if skipped.any?
    puts "Updated (#{updated.size})\n- #{updated.map(&:name).join("\n- ")}\n\n" if updated.any?
    puts "Errored (#{errored.size})\n- #{errored.map(&:name).join("\n- ")}\n\n" if errored.any?
  end

  desc 'install USER/BUNDLE', 'Install a bundle from GitHub (e.g. tmb install elia/bundler)'
  def install name
    name = BundleName.new(name)
    install_path = bundles_dir.join(name.install_name).to_s
    system('git', 'clone', name.git_url, install_path)
  end

  desc 'status [BUNDLE]', 'Check the status of your local copy of the bundle'
  def status name = nil
    bundles_list.all.each do |bundle|
      within bundle do
        puts "== #{bundle.name}"
        system('git', 'fetch')
        system('git', 'status', '--porcelain')
        puts
      end
    end
  end

  desc 'list', 'lists all installed bundles'
  def list
    bundles_list.all.each do |bundle|
      puts "- #{bundle.name.ljust(30)} (#{bundle.path})"
    end
  end



  private

  def within bundle
    Dir.chdir bundle.path do
      yield
    end
  end

  def installed_bundles
    bundles_list.all
  end

  def bundles_list
    @bundles_list ||= BundlesList.new(bundles_dir)
  end

  def bundles_dir
    @bundles_dir ||= Pathname('~/Library/Application Support/Avian/Bundles').expand_path
  end

  class BundlesList < Struct.new(:dir)
    def all
      @all ||= Dir[dir.join('*/.git').to_s].map do |path|
        Bundle.new(Pathname(path).join('..').to_s)
      end
    end
  end

  class Bundle < Struct.new(:path)
    def name
      @name ||= File.basename(path, '.tmbundle')
    end
  end

  def mate *args
    exec 'mate', *args
  end
end

