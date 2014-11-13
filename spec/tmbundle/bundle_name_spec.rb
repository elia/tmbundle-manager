require 'spec_helper'
require 'tmbundle'
require 'tmbundle/bundle_name'

describe TMBundle::BundleName do
  endings = ['-tmbundle', '.tmbundle', '']

  endings.each do |ending|
    context "ending in #{ending.inspect}" do
      subject(:name) { described_class.new("davidrios/jade#{ending}") }
      its(:name)         { should eq("davidrios/jade#{ending}") }
      its(:install_name) { should eq('jade.tmbundle') }
      its(:git_url)      { should eq("https://github.com/davidrios/jade#{ending.empty? ? '.tmbundle' : ending}.git") }
    end
  end
end
