require File.join(File.dirname(__FILE__), 'test_helper')


describe "parameters" do

  let(:param) do
    {
      "priority" => nil,
      "created_at" => "2015-12-03T01:57:55Z",
      "updated_at" => "2015-12-03T01:57:55Z",
      "id" => 15,
      "name" => "B",
      "value" => "2"
    }
  end

  describe "set" do

    before do
      @cmd = ["location", "set-parameter"]
    end

    it "should print error on missing --name" do
      params = ['--value=1']

      expected_result = usage_error_result(
        @cmd,
        "Option '--name' is required.",
        "Could not set location parameter"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error on missing --value" do
      params = ['--name=A']

      expected_result = usage_error_result(
        @cmd,
        "Option '--value' is required.",
        "Could not set location parameter"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should create new parameter" do
      params = ['--name=A', '--value=1', '--parameter-type=integer', '--location-id=3']

      api_expects(:parameters, :index, 'Attempt find parameters') do |par|
        par['location_id'].to_i == 3
      end.returns(index_response([]))
      api_expects(:parameters, :create, 'Create parameter') do |par|
        par['parameter']['name'] == 'A' &&
        par['parameter']['value'] == '1' &&
        par['parameter']['parameter_type'] == 'integer'
      end.returns({:name => 'A', :value => '1'})

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Parameter [A] created with value [1]\n"), result)
    end


    it "should update existing parameter" do
      params = ['--name=A', '--value=1', '--parameter-type=integer', '--location-id=3']

      api_expects(:parameters, :index, 'Find parameter') do |par|
        par['location_id'].to_i == 3
      end.returns(index_response([param]))
      api_expects(:parameters, :update, 'Update parameter') do |par|
        par['id'].to_i == 15 &&
        par['location_id'].to_i == 3 &&
        par['parameter']['value'] == '1' &&
        par['parameter']['parameter_type'] == 'integer'
      end.returns({:name => 'A', :value => '1'})

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Parameter [A] updated to value [1]\n"), result)
    end
  end


  describe "delete" do
    before do
      @cmd = ["location", "delete-parameter"]
    end

    it "should print error on missing --name" do
      params = []

      expected_result = usage_error_result(
        @cmd,
        "Option '--name' is required.",
        "Could not delete location parameter"
      )

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should print error when the parameter doesn't exist" do
      params = ['--name=A', '--location-id=3']

      api_expects(:parameters, :index, 'Find parameter') do |par|
        par['location_id'].to_i == 3
      end.returns(index_response([]))

      expected_result = common_error_result(
        @cmd,
        "parameter not found.",
        "Could not delete location parameter"
      )

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it "should delete the parameter" do
      params = ['--name=A', '--location-id=3']

      api_expects(:parameters, :index, 'Find parameter') do |par|
        par['location_id'].to_i == 3
      end.returns(index_response([param]))
      api_expects(:parameters, :destroy, 'Delete parameter') do |par|
        par['id'] == param['id']
      end.returns({:name => 'A', :value => '1'})

      expected_result = success_result(
        "Parameter [A] deleted.\n"
      )

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end
  end
end

describe 'create' do
  before do
    @cmd = %w(location create)
  end

  it 'should print error missing argument name' do
    expected_result = "Could not create the location:\n  Missing arguments for '--name'.\n"

    api_expects(:locations, :index)

    result = run_cmd(@cmd)
    assert_match(expected_result, result.err)
  end

  it 'should create a location' do
    params = ['--name=test-location']

    api_expects(:locations, :index)
    api_expects(:locations, :create, 'Create a locations') do |params|
      (params['location']['name'] == 'test-location')
    end

    result = run_cmd(@cmd + params)
    assert_cmd(success_result("Location created.\n"), result)
  end
end

describe 'delete' do
  before do
    @cmd = %w(location delete)
  end

  it 'should print error missing argument id' do
    expected_result = "Could not delete the location:\n  Missing arguments for '--id'.\n"

    api_expects(:locations, :index)

    result = run_cmd(@cmd)
    assert_match(expected_result, result.err)
  end

  it 'should delete a location' do
    params = ['--id=1']

    api_expects(:locations, :index)
    api_expects(:locations, :destroy, 'Delete a location').with_params(id: '1')

    result = run_cmd(@cmd + params)
    assert_cmd(success_result("Location deleted.\n"), result)
  end
end

describe 'info' do
  before do
    @cmd = ['location', 'info']
    @location = {
        id: 1,
        title: 'Default Location',
        name: 'Default Location',
        users: [],
        smart_proxies: [],
        subnets: [],
        compute_resources: [],
        media: [],
        ptables: [],
        provisioning_templates: [],
        domains: [],
        realms: [],
        environments: [],
        hostgroups: [],
        organizations: [],
        parameters: []
    }
  end

  it 'should return the info of a location' do
    params = ['--id', 1]
    api_expects(:locations, :index)
    api_expects(:locations, :show, 'Info location').returns(@location)

    output = OutputMatcher.new([
                                 'Id:                 1',
                                 'Title:              Default Location',
                                 'Name:               Default Location',
                                 'Users:',
                                 '',
                                 'Smart proxies:',
                                 '',
                                 'Subnets:',
                                 '',
                                 'Compute resources:',
                                 '',
                                 'Installation media:',
                                 '',
                                 'Templates:',
                                 '',
                                 'Partition Tables:',
                                 '',
                                 'Domains:',
                                 '',
                                 'Realms:',
                                 '',
                                 'Environments:',
                                 '',
                                 'Hostgroups:',
                                 '',
                                 'Parameters:',
    ])

    expected_result = success_result(output)
    result = run_cmd(@cmd + params)
    assert_cmd(expected_result, result)
  end
end

describe 'update' do
  before do
    @cmd = ['location', 'update']
  end

  it 'should update a location' do
    params = ['--id=1', '--new-name=Default Location test']

    api_expects(:locations, :index)
    api_expects(:locations, :update, 'Update a location') do |params|
      (params['location']['id'] == '1')
      (params['location']['name'] == 'Default Location test')
    end

    result = run_cmd(@cmd + params)
    assert_cmd(success_result("Location updated.\n"), result)
  end
end
