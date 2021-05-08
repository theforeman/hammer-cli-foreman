require File.join(File.dirname(__FILE__), 'test_helper')

describe 'template' do
  describe 'clone' do
    before do
      @cmd = %w(template clone)
    end

    it 'should print error on missing --id' do
      params = ['--new-name=zzz']

      expected_result = CommandExpectation.new
      expected_result.expected_err =
        ['Could not clone the provisioning template:',
         "  Missing arguments for '--id'.",
         ''].join("\n")
      expected_result.expected_exit_code = HammerCLI::EX_USAGE

      api_expects_no_call

      result = run_cmd(@cmd + params)

      assert_cmd(expected_result, result)
    end

    it 'should print error on missing --new-name' do
      params = ['--id=1']

      expected_result = usage_error_result(
        @cmd,
        'Option --new-name is required.',
        'Could not clone the provisioning template')

      api_expects_no_call

      result = run_cmd(@cmd + params)

      assert_cmd(expected_result, result)
    end

    it 'should clone a template by id' do
      params = ['--id=1', '--new-name=zzz']

      api_expects(:provisioning_templates, :clone, 'Clone template') do |par|
        par['id'] == '1' && par['name'] == 'zzz'
      end.returns(:name => 'A', :value => '1')

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Provisioning template cloned.\n"), result)
    end

    it 'should clone a template by name' do
      params = ['--name=old', '--new-name=zzz']

      api_expects(:provisioning_templates, :index, 'Attempt find template') do |par|
        par[:search] == 'name = "old"'
      end.returns(
        index_response(
          [{
            'snippet' => false,
            'audit_comment' => nil,
            'created_at' => '2016-02-29 14:32:57 UTC',
            'updated_at' => '2016-02-29 14:32:57 UTC',
            'id' => 1,
            'name' => 'zzz',
            'template_kind_id' => 7,
            'template_kind_name' => 'user_data'
          }]))

      api_expects(:provisioning_templates, :clone, 'Clone template') do |par|
        par['id'] == 1 && par['provisioning_template']['name'] == 'zzz'
      end.returns(:name => 'A', :value => '1')

      result = run_cmd(@cmd + params)

      assert_cmd(success_result("Provisioning template cloned.\n"), result)
    end
  end

  describe 'update' do
    before do
      @cmd = %w(template update)
    end

    it "doesn't send snippet flag when --type is undefined" do
      params = ['--id=1', '--locked=true']

      api_expects(:template_kinds, :index, 'Get list of template kinds').returns(index_response([]))
      api_expects(:provisioning_templates, :update, 'Update the template') do |par|
        par['id'] == '1' &&
        par['provisioning_template']['locked'] == true
      end.returns(:name => 'A', :value => '1')

      result = run_cmd(@cmd + params)

      assert_cmd(success_result("Provisioning template updated.\n"), result)
    end

    it 'updates nothing without template related parameters' do
      params = %w[--id=1 --organization-id=1 --location-id=1]

      api_expects(:template_kinds, :index, 'Get list of template kinds').returns(index_response([]))
      api_expects(:provisioning_templates, :update, 'Update template with no params').returns({})

      expected_result = success_result("Nothing to update.\n")

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'create' do
    before do
      @cmd = %w(template create)
    end

    it 'should print correct error on providing unknown template kind' do
      params = ['--name=tpl', '--file=Gemfile', '--type=unknown']

      expected_result = CommandExpectation.new
      expected_result.expected_err =
        ['Could not create the provisioning template:',
         "  Error: unknown template kind",
         '  ',
         "  See: 'hammer template create --help'.",
         ''].join("\n")
      expected_result.expected_exit_code = HammerCLI::EX_USAGE

      HammerCLIForeman::Template::CreateCommand.any_instance.stubs(:kinds).returns(["PXELinux"])

      api_expects_no_call

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'combinations' do
    before do
      @cmd = %w(template combination)
    end

    it 'should create new combination with warning' do
      params = ['create','--provisioning-template-id=10', '--hostgroup-id=1', '--environment-id=1']
      expected_result = success_result("Template combination created.\n")
      expected_result.expected_err = "Warning: Option --environment-id is deprecated. Use --puppet-environment[-id] instead\n"
      api_expects(:template_combinations, :create, 'Create template combination') do |params|
        params['provisioning_template_id'] == 10 &&
          params['hostgroup_id'] == 1 &&
          params['environment_id'] == 1 &&
          params['template_combination'] == {'environment_id' => 1, 'hostgroup_id' => 1}
      end

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'should create new combination' do
      params = ['create','--provisioning-template-id=10', '--hostgroup-id=1', '--puppet-environment-id=1']
      expected_result = success_result("Template combination created.\n")
      api_expects(:template_combinations, :create, 'Create template combination') do |params|
        params['provisioning_template_id'] == 10 &&
          params['hostgroup_id'] == 1 &&
          params['environment_id'] == 1 &&
          params['template_combination'] == {'environment_id' => 1, 'hostgroup_id' => 1}
      end

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'should update combination with warning' do
      params = ['update', '--id=3', '--provisioning-template-id=10', '--hostgroup-id=1', '--environment-id=1']
      expected_result = success_result("Template combination updated.\n")
      expected_result.expected_err = "Warning: Option --environment-id is deprecated. Use --puppet-environment[-id] instead\n"
      api_expects(:template_combinations, :update, 'Update template combination') do |params|
        params['id'] == '3' &&
          params['provisioning_template_id'] == 10 &&
          params['hostgroup_id'] == 1 &&
          params['environment_id'] == 1 &&
          params['template_combination'] == { 'environment_id' => 1, 'hostgroup_id' => 1 }
      end

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'should update combination' do
      params = ['update', '--id=3', '--provisioning-template-id=10', '--hostgroup-id=1', '--puppet-environment-id=1']
      expected_result = success_result("Template combination updated.\n")
      api_expects(:template_combinations, :update, 'Update template combination') do |params|
        params['id'] == '3' &&
          params['provisioning_template_id'] == 10 &&
          params['hostgroup_id'] == 1 &&
          params['environment_id'] == 1 &&
          params['template_combination'] == { 'environment_id' => 1, 'hostgroup_id' => 1 }
      end

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

  end
end
