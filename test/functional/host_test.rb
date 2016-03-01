require File.join(File.dirname(__FILE__), 'test_helper')


describe "host create" do
  let(:cmd) { ["host", "create"] }
  let(:minimal_params) { ['--hostgroup-id=1', '--location-id=1', '--organization-id=1', '--name=test'] }

  it "passes interface attributes to server" do
    params = ['--interface', 'identifier=eth0,ip=10.0.0.4,primary=true,provision=true']

    api_expects(:hosts, :create, 'Create host with interfaces params') do |par|
      ifces = par['host']['interfaces_attributes']

      ifces.length == 1 &&
      ifces[0]['ip'] == '10.0.0.4' &&
      ifces[0]['identifier'] == 'eth0'
    end.returns({})

    expected_result = success_result("Host created\n")

    result = run_cmd(cmd + minimal_params + params)
    assert_cmd(expected_result, result)
  end

  it "sends empty hash for no interfaces" do
    # For some reason the Foreman replaces empty interfaces_attributes to nil,
    # which causes failure in nested attributes assignment in the host model

    api_expects(:hosts, :create, 'Create host with empty interfaces') do |par|
      par['host']['interfaces_attributes'] == {}
    end.returns({})

    expected_result = success_result("Host created\n")

    result = run_cmd(cmd + minimal_params)
    assert_cmd(expected_result, result)
  end
end
