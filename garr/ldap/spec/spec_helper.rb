require 'rspec-puppet'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'mocha'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
support_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec/support/*.rb'))
Dir[support_path].each {|f| require f}

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.mock_with :mocha
end

