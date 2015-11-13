require File.join(File.dirname(__FILE__), '../test_helper')

def ctx
  {
    :adapter => :silent,
    :username => 'admin',
    :password => 'admin',
    :interactive => false
  }
end


require File.join(File.dirname(__FILE__), 'test_output_adapter')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')
require File.join(File.dirname(__FILE__), 'helpers/command')
require File.join(File.dirname(__FILE__), 'helpers/resource_disabled')

HammerCLI::Settings.load({:_params => {:interactive => false}})
