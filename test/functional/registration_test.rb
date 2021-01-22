require File.join(File.dirname(__FILE__), 'test_helper')

describe 'registration_commands' do
  it 'create' do
    api_expects(:registration_commands, :create)
    run_cmd(%w(host-registration generate-command))
  end
end
