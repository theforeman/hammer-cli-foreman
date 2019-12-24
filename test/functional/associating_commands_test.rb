require File.join(File.dirname(__FILE__), 'test_helper')

require 'hammer_cli_foreman/operating_system'

describe HammerCLIForeman::OperatingSystem do
  context "AddProvisioningTemplateCommand" do
    before do
      @cmd = ["os", "add-provisioning-template"]
      @os_before_update = {
        id: 1,
        provisioning_templates: []
      }
      @os_after_update1 = {
        id: 1,
        provisioning_templates: [{ id: 1, name: 'test template' }]
      }
      @os_after_update2 = {
        id: 1,
        provisioning_templates: [{ id: 1, name: 'test template 1' },
                                 { id: 2, name: 'test template 2' }]
      }
      @search_result = [{ 'id' => 1, 'name' => 'test template 1'}, { 'id' => 2, 'name' => 'test template 2'}]
      @provisioning_templates = [{ 'id' => 1, 'name' => 'test template 1' }, { 'id' => 2, 'name' => 'test template 2' }]
    end

    it "should print error on missing --id" do
      expected_result = "Could not associate the provisioning templates:\n  Missing arguments for '--id'\n"

      api_expects_no_call
      result = run_cmd(@cmd)
      assert_match(expected_result, result.err)
    end

    it "should associate the given provisioning template-by id" do
      params = ['--id=1', '--provisioning-template-id=1']

      api_expects(:operatingsystems, :show).with_params({ "id": "1" }).returns(@os_before_update)

      api_expects(:operatingsystems, :update) do |par|
        par['id'] == '1' &&
          par['operatingsystem'] == { 'provisioning_template_ids' => ['1'] }
      end.returns(@os_after_update1)

      result = run_cmd(@cmd + params)
      assert_cmd(
        success_result("The provisioning templates were associated.\n"),
        result
      )
    end

    it "should associate all given provisioning templates - by ids" do
      params = ['--id=1', '--provisioning-template-ids=1,2']

      api_expects(:operatingsystems, :show).with_params({ "id": "1" }).returns(@os_before_update)

      api_expects(:operatingsystems, :update) do |par|
        par['id'] == '1' &&
          par['operatingsystem'] == { 'provisioning_template_ids' => ['1', '2'] }
      end.returns(@os_after_update2)

      result = run_cmd(@cmd + params)
      assert_cmd(
        success_result("The provisioning templates were associated.\n"),
        result
      )
    end

    it "should associate all given provisioning templates - by names" do
      params = ['--id=1', '--provisioning-templates=test template 1,test template 2']

      api_expects(:operatingsystems, :show).with_params({ "id": "1" }).returns(@os_before_update)
      api_expects(:provisioning_templates, :index).with_params(
        :search => "name = \"test template 1\" or name = \"test template 2\"",
        :per_page => 1000,
        :page => 1).returns(@search_result)
      api_expects(:operatingsystems, :update) do |par|
        par['id'] == '1' &&
        par['operatingsystem'] == { 'provisioning_template_ids' => ['1', '2'] }
      end.returns(@os_afterd_update2)

      result = run_cmd(@cmd + params)
      assert_cmd(
          success_result("The provisioning templates were associated.\n"),
          result
      )
    end

    it "should associate all provisioning templates that match the given search" do
      params = ['--id=1', '--provisioning-template-search=test']

      api_expects(:operatingsystems, :show).with_params({ "id": "1" }).returns(@os_before_update)
      api_expects(:provisioning_templates, :index).returns(@provisioning_templates)
      api_expects(:operatingsystems, :update) do |par|
        par['id'] == '1' &&
          par['operatingsystem'] == { 'provisioning_template_ids' => ['1', '2'] }
      end.returns(@os_afterd_update2)

      result = run_cmd(@cmd + params)
      assert_cmd(
          success_result("The provisioning templates were associated.\n"),
          result
      )
    end

  end
end
