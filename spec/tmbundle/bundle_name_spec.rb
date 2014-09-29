require 'spec_helper'
require 'tmbundle'
require 'tmbundle/bundle_name'

describe TMBundle::BundleName do
  subject(:name) { described_class.new('davidrios/jade-tmbundle') }
  its(:name)         { should eq('davidrios/jade-tmbundle') }
  its(:install_name) { should eq('jade.tmbundle') }
  its(:git_url)      { should eq('https://github.com/davidrios/jade-tmbundle.git') }
end
