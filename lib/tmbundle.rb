# coding: utf-8
require 'pathname'
require 'thor'

class TMBundle < Thor
  desc 'edit PARTIAL_NAME', 'Edit an installed bundle (name will be matched against PARTIAL_NAME)'
  def edit partial_name
    bundle = find_bundle(partial_name)
    mate bundle.path
  rescue NotFound
    return false
  end

  desc 'update [PARTIAL_NAME]', 'Update installed bundles'
  def update(partial_name = nil)
    bundle = find_bundle(partial_name) if partial_name
    bundles_to_update = bundle ? [bundle] : installed_bundles

    require 'thread'
    signals = Queue.new
    trap('INT') { signals << :int }

    updated = []
    skipped = []
    errored = []

    bundles_to_update.each do |bundle|
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
    require 'tmbundle/bundle_name'
    name = BundleName.new(name)
    install_path = bundles_dir.join(name.install_name).to_s
    success = system('git', 'clone', name.git_url, install_path)
    if not success
      puts "attempting clone of #{name.alt_git_url}"
      success = system('git', 'clone', name.alt_git_url, install_path)
    end
  end

  desc 'path NAME', 'print path to bundle dir'
  def path name
    puts find_bundle(name).path
  rescue NotFound
    return false
  end

  desc 'status [BUNDLE]', 'Check the status of your local copy of the bundle'
  def status name = nil
    justification = 50
    bundles_list.all.each do |bundle|
      within bundle do
        print "- #{bundle.name}...".ljust(justification)
        # puts "-> fetching updates from remote..."
        `git fetch -aq 2> /dev/null`
        fetch_successful = $?.success?
        # puts "-> checking status..."
        branch_info, *changes = `git status -zb`.split("\0")
        branch, remote, branch_status,  = branch_info.scan(/^## (\S+)\.\.\.(\S+)(?: \[(.+)\])?/).flatten
        cd_hint = false

        if changes.any?
          cd_hint = true
          print "✘ #{changes.size} changed/new file#{:s if changes.size != 0}.".ljust(justification)
        else
          case branch_status.to_s
          when /^ahead (\d+)/
            ahead_commits = $1
            cd_hint = true
            print "✘ #{ahead_commits} commits ahead of #{remote}. ".ljust(justification)
          when /^behind (\d+)/
            behind_commits = $1
            cd_hint = true
            print "❍ behind remote (#{remote}) by #{behind_commits}. ".ljust(justification)
          else
            print "✔︎ up-to-date"
          end
        end
        print "$ cd \"#{bundle.path}\" # to enter the bundle directory" if cd_hint
        puts
        puts "#{' '*justification}✘✘✘ Something went wrong while fetching from remote #{remote}" unless fetch_successful
      end
    end
  end

  desc 'list', 'lists all installed bundles'
  def list
    bundles_list.all.each do |bundle|
      puts "- #{bundle.name.ljust(30)} (#{bundle.path})"
    end
  end

  desc 'cd PARTIAL_NAME', 'open a terminal in the bundle dir'
  def cd(partial_name)
    bundle = find_bundle(partial_name)
    within bundle do
      system 'open', bundle.path, '-a', 'Terminal.app'
    end
  end



  private

  def find_bundle(partial_name)
    matches = installed_bundles.select do |bundle|
      bundle.name =~ /^#{partial_name}/i
    end

    if matches.size > 1
      puts "please be more specific:"
      matches.each_with_index {|m,i| puts " #{i+1}) #{m.name}"}
      print 'Type the number> '
      return(matches[$stdin.gets.to_i-1] || raise(NotFound))
    end

    if matches.empty?
      puts "nothing found"
      raise NotFound
    end

    matches.first
  end

  class NotFound < StandardError
  end

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

