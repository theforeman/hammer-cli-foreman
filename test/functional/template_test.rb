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

  describe 'import' do
    let(:template) do
      {
        'id' => 1,
        'template' => 'Template content'
      }
    end
    let(:cmd) { %w(template import) }
    let(:tempfile) { Tempfile.new('template') }

    it 'requires --name and --file' do
      params = ['--name=test']
      api_expects_no_call
      expected_result = usage_error_result(
        cmd,
        'Options --name, --file are required.',
        'Could not import provisioning template')
      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'import template' do
      params = ['--name=test', "--file=#{tempfile.path}"]
      tempfile.write('Template content')
      tempfile.rewind
      api_expects(:provisioning_templates, :import, 'Import template').with_params(
        'provisioning_template' => {
          'name' => 'test',
          'template' => 'Template content'
        }).returns(template)

      result = run_cmd(cmd + params)
      assert_cmd(success_result("Import provisioning template succeeded.\n"), result)
    end
  end

  describe 'export' do
    let(:cmd) { %w(template export) }
    let(:tempfile) { Tempfile.new('template', '/tmp') }
    let(:params) { ['--id=1', '--path=/tmp'] }
    let(:template_response) do
      response = mock('TemplateResponse')
      response.stubs(:code).returns(200)
      response.stubs(:body).returns('Template content')
      response.stubs(:headers).returns({:content_disposition => "filename=\"#{File.basename(tempfile.path)}\""})
      response
    end

    it 'download template' do
      api_expects(:provisioning_templates, :export, 'Export template').with_params(
        'id' => '1').returns(template_response)

      output = OutputMatcher.new("The provisioning template has been saved to #{tempfile.path}")
      expected_result = success_result(output)
      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
      assert_equal('Template content', tempfile.read)
    end
  end

  describe 'update' do
    before do
      @cmd = %w(template update)
    end

    it "doesn't send snippet flag when --type is undefined" do
      params = ['--id=1', '--locked=true']

      api_expects(:provisioning_templates, :update, 'Update the template') do |par|
        par['id'] == '1' &&
        par['provisioning_template']['locked'] == true
      end.returns(:name => 'A', :value => '1')

      result = run_cmd(@cmd + params)

      assert_cmd(success_result("Provisioning template updated.\n"), result)
    end

    it 'updates nothing without template related parameters' do
      params = %w[--id=1 --organization-id=1 --location-id=1]

      api_expects(:provisioning_templates, :update, 'Update template with no params').returns({})

      expected_result = success_result("Nothing to update.\n")

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'should update a template' do
      params = ['--id=1', '--type=snippet']

      expected_result = CommandExpectation.new
      expected_result.expected_out =
        ['Provisioning template updated.',
         ''].join("\n")
      expected_result.expected_exit_code = HammerCLI::EX_OK

      api_expects(:provisioning_templates, :update, 'Update template with params') do |p|
        p['id'] == '1' && p['provisioning_template']['snippet'] == true
      end

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'should update a template by name' do
      params = ['--name=tpl', '--type=provision']

      expected_result = CommandExpectation.new
      expected_result.expected_out =
        ['Provisioning template updated.',
         ''].join("\n")
      expected_result.expected_exit_code = HammerCLI::EX_OK

      api_expects_search(:provisioning_templates, name: 'tpl').returns(
        index_response([{ 'id' => '1' }])
      )
      api_expects_search(:template_kinds, name: 'provision').returns(
        index_response([{ 'id' => '1' }])
      )
      api_expects(:provisioning_templates, :update, 'Update template with params') do |p|
        p['id'] == '1' &&
          p['provisioning_template']['snippet'] == false &&
          p['provisioning_template']['template_kind_id'] == '1'
      end

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
         '  Error: template_kind not found.',
         ''].join("\n")
      expected_result.expected_exit_code = HammerCLI::EX_SOFTWARE

      api_expects_search(:template_kinds, name: 'unknown').returns(
        index_response([])
      )

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'should create a template' do
      params = ['--name=tpl', '--file=Gemfile', '--type=provision']

      expected_result = CommandExpectation.new
      expected_result.expected_out =
        ['Provisioning template created.',
         ''].join("\n")
      expected_result.expected_exit_code = HammerCLI::EX_OK

      api_expects_search(:template_kinds, name: 'provision').returns(
        index_response([{ 'id' => '1' }])
      )
      api_expects(:provisioning_templates, :create, 'Create template with params') do |p|
        p['provisioning_template']['name'] == 'tpl' &&
          p['provisioning_template']['snippet'] == false &&
          p['provisioning_template']['template_kind_id'] = '1'
      end

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'combinations' do
    before do
      @cmd = %w(template combination)
    end

    it 'should create new combination' do
      params = ['create','--provisioning-template-id=10', '--hostgroup-id=1']
      expected_result = success_result("Template combination created.\n")
      api_expects(:template_combinations, :create, 'Create template combination') do |params|
        params['provisioning_template_id'] == '10' &&
          params['hostgroup_id'] == '1' &&
          params['template_combination'] == { 'hostgroup_id' => '1' }
      end

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'should update combination' do
      params = ['update', '--id=3', '--provisioning-template-id=10', '--hostgroup-id=1']
      expected_result = success_result("Template combination updated.\n")
      api_expects(:template_combinations, :update, 'Update template combination') do |params|
        params['id'] == '3' &&
          params['provisioning_template_id'] == '10' &&
          params['hostgroup_id'] == '1' &&
          params['template_combination'] == { 'hostgroup_id' => '1' }
      end

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

  end
end
