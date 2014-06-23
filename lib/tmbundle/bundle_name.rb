class TMBundle::BundleName
  def initialize(name)
    @name = name
  end

  attr_reader :name
  private :name

  def install_name
    File.basename(name.gsub(/([\.\-_]tmbundle)?$/i, '.tmbundle'))
  end

  def repo_name
    name+'.tmbundle' unless name =~ /([\.\-_]tmbundle)$/i
  end

  def git_url
    "https://github.com/#{repo_name}.git"
  end
end
