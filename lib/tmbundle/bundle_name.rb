class TMBundle::BundleName
  REGEX = /([_\.\-]tmbundle)$/i

  def initialize(name)
    @name = name
  end

  attr_reader :name
  private :name

  def install_name
    File.basename(name =~ REGEX ? name.gsub(REGEX, '.tmbundle') : name+'.tmbundle')
  end

  def repo_name
    name =~ REGEX ? name : name+'.tmbundle'
  end

  def git_url
    "https://github.com/#{repo_name}.git"
  end

  def alt_git_url
    git_url.gsub('.tmbundle', '-tmbundle')
  end
  
  def inspect
    "#<TMBundle::BundleName @name=#@name repo_name:#{repo_name} git_url:#{git_url} install_name:#{install_name}>"
  end
end
