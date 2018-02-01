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
         "  Missing arguments for 'id'",
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

      api_expects(:config_templates, :clone, 'Clone template') do |par|
        par['id'] == '1' && par['config_template']['name'] == 'zzz'
      end.returns(:name => 'A', :value => '1')

      result = run_cmd(@cmd + params)

      assert_cmd(success_result("Provisioning template cloned.\n"), result)
    end

    it 'should clone a template by name' do
      params = ['--name=old', '--new-name=zzz']

      api_expects(:config_templates, :index, 'Attempt find template') do |par|
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

      api_expects(:config_templates, :clone, 'Clone template') do |par|
        par['id'] == 1 && par['config_template']['name'] == 'zzz'
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
      api_expects(:config_templates, :update, 'Update the template') do |par|
        par['config_template']['locked'] == true &&
        par['config_template']['snippet'].nil?
      end.returns(:name => 'A', :value => '1')

      result = run_cmd(@cmd + params)

      assert_cmd(success_result("Provisioning template updated.\n"), result)
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
end
