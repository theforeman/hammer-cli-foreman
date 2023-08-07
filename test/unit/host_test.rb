require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/host'

describe HammerCLIForeman::Host do

  include CommandTestHelper

  describe "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:hosts, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Host::ListCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    describe "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_columns ["Id", "Name", "Operating System", "Host Group", "IP", "MAC", "Global Status"]
    end

  end

  describe "InfoCommand" do
    before do
      ResourceMocks.hosts_show
    end

    let(:cmd) { HammerCLIForeman::Host::InfoCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=host"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    describe "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_columns ["Id", "Name", "Organization", "Location"]
        it_should_print_columns ["Host Group", "Compute Resource", "Compute Profile"]
        it_should_print_columns ["Managed", "Status", "Installed at", "Last report"]
        it_should_print_columns ["Network", "Network interfaces", "Operating system", "Parameters", "All parameters", "Additional info"]
      end
    end

  end

  describe "StatusCommand" do

    let(:cmd) { HammerCLIForeman::Host::StatusCommand.new("", ctx) }

    before :each do
      ResourceMocks.mock_action_call(:hosts, :power, { 'power' => 'running' } )
      ResourceMocks.mock_action_call(:hosts, :get_status, { 'status_label' => 'No reports' } )
    end

    describe "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no arguments"
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    describe "output" do
      with_params ["--id=1"] do
        it_should_print_columns ["Status", "Power"]

        it "should output status" do
          cmd.stubs(:context).returns(ctx.update(:adapter => :test))
          _(proc { cmd.run(with_params) }).must_output "#Status#Power#\n#No reports#running#\n"
        end
      end
    end

  end

  describe "FactsCommand" do

    let(:cmd) { HammerCLIForeman::Host::FactsCommand.new("", ctx) }

    before(:each) do
      ResourceMocks.facts_index
    end

    describe "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no arguments"
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    describe "output" do
      with_params ["--name=my5name.mydomain.net"] do
        it_should_print_column "Fact"
        it_should_print_column "Value"
      end
    end
  end

  describe "ConfigReportsCommand" do
    before do
      ResourceMocks.mock_action_call(:config_reports, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Host::ConfigReportsCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=my.test.host.org"]
    end

    describe "output" do
      with_params ["--id=1"] do
        let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

        it_should_print_n_records
        it_should_print_column "Id"
        it_should_print_column "Host"
        it_should_print_column "Last report"
        it_should_print_column "Applied"
        it_should_print_column "Restarted"
        it_should_print_column "Failed"
        it_should_print_column "Restart Failures"
        it_should_print_column "Skipped"
        it_should_print_column "Pending"
      end
    end

  end

  describe "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Host::DeleteCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "name or id missing", []
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

  describe "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Host::CreateCommand.new("", ctx) }

    before :each do
      HammerCLIForeman::Hosts::CommonUpdateOptions.stubs(:ask_password).returns("password")
    end

    describe "parameters" do
      taxonomies = ["--organization-id=1", "--location-id=1"]
      it_should_accept "name, architecture_id, domain_id, operatingsystem_id and more",
          ["--name=host", "--architecture-id=1", "--domain-id=1", "--operatingsystem-id=1",
            "--ip=1.2.3.4", "--mac=11:22:33:44:55:66", "--medium-id=1", "--partition-table-id=1", "--subnet-id=1",
            "--model-id=1", "--hostgroup-id=1", "--owner-id=1",
            "--root-password=pwd", "--ask-root-password=true", "--provision-method=build", "--interface=primary=true,provision=true"] + taxonomies
      it_should_fail_with "name or id missing",
          ["--architecture-id=1", "--domain-id=1", "--operatingsystem-id=1", "--interface=primary=true,provision=true"]
      it_should_fail_with "architecture_id missing",
          ["--name=host", "--domain-id=1", "--operatingsystem-id=1", "--interface=primary=true,provision=true"]
      it_should_fail_with "domain_id missing",
          ["--name=host", "--architecture-id=1", "--operatingsystem-id=1", "--interface=primary=true,provision=true"]
      it_should_fail_with "operatingsystem_id missing",
          ["--name=host", "--architecture-id=1", "--domain-id=1", "--interface=primary=true,provision=true"]
      it_should_accept "only hostgroup name", ["--hostgroup=example", "--name=host", "--interface=primary=true,provision=true"] + taxonomies
      it_should_accept "only hostgroup ID", ["--hostgroup-id=1", "--name=host", "--interface=primary=true,provision=true"] + taxonomies

      with_params ["--name=host", "--architecture-id=1", "--domain-id=1", "--operatingsystem-id=1",
            "--ip=1.2.3.4", "--mac=11:22:33:44:55:66", "--medium-id=1", "--partition-table-id=1", "--subnet-id=1",
            "--model-id=1", "--hostgroup-id=1", "--owner-id=1",
            "--root-password=pwd", "--ask-root-password=true", "--provision-method=build", "--interface=primary=true,provision=true"] do
        it_should_call_action_and_test_params(:create) { |par| par["host"]["managed"] == true }
        it_should_call_action_and_test_params(:create) { |par| par["host"]["build"] == true }
        it_should_call_action_and_test_params(:create) { |par| par["host"]["enabled"] == true }
        it_should_call_action_and_test_params(:create) { |par| par["host"]["provision_method"] == "build" }
        it_should_call_action_and_test_params(:create) { |par| par["host"]["interfaces_attributes"][0]["primary"] == "true" }
        it_should_call_action_and_test_params(:create) { |par| par["host"]["interfaces_attributes"][0]["provision"] == "true" }
      end

      with_params ["--name=host", "--hostgroup-id=1", "--interface=primary=true,provision=true", "--parameters=servers=[pool.ntp.org,ntp.time.org],password=secret"] do
        it_should_call_action_and_test_params(:create) do |par|
          par["host"]["host_parameters_attributes"][0]["value"] == "[\"pool.ntp.org\", \"ntp.time.org\"]" &&
          par["host"]["host_parameters_attributes"][1]["value"] == "secret"
        end
      end

      it_should_fail_with "primary interface missing", ["--hostgroup-id=example", "--interface=primary=true"]
      it_should_fail_with "provision interface missing", ["--hostgroup-id=example", "--interface=provision=true"]
    end
  end

  describe "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Host::UpdateCommand.new("", ctx) }

    before :each do
      HammerCLIForeman::Hosts::CommonUpdateOptions.stubs(:ask_password).returns("password")
    end

    describe "parameters" do
      it_should_accept "name", ["--name=host", "--new-name=host2"]
      it_should_accept "id and more", ["--id=1", "--new-name=host2", "--architecture-id=1",
            "--domain-id=1", "--operatingsystem-id=1",
            "--ip=1.2.3.4", "--mac=11:22:33:44:55:66", "--medium-id=1", "--partition-table-id=1", "--subnet-id=1",
            "--model-id=1", "--hostgroup-id=1", "--owner-id=1",
            "--root-password=pwd", "--ask-root-password=true", "--provision-method=build"]
      # it_should_fail_with "no params", []
      # it_should_fail_with "name or id missing", ["--new-name=host2"]
      # TODO: temporarily disabled, parameters are checked in the id resolver

      with_params ["--id=1"] do
        it_should_call_action_and_test_params(:update) { |par| par["host"].key?("managed") != true }
        it_should_call_action_and_test_params(:update) { |par| par["host"].key?("build") != true }
        it_should_call_action_and_test_params(:update) { |par| par["host"].key?("enabled") != true }
        it_should_call_action_and_test_params(:update) { |par| par["host"].key?("overwrite") != true }
      end

      with_params ["--id=1", "--enabled=true"] do
        it_should_call_action_and_test_params(:update) { |par| par["host"]["enabled"] == true }
      end

      with_params ["--id=1", "--enabled=false"] do
        it_should_call_action_and_test_params(:update) { |par| par["host"]["enabled"] == false }
      end

      with_params ["--id=1", "--overwrite=true"] do
        it_should_call_action_and_test_params(:update) { |par| par["host"]["overwrite"] == true }
      end

      with_params ["--id=1","--provision-method=build"] do
        it_should_call_action_and_test_params(:update) { |par| par["host"]["provision_method"] == "build" }
      end

      # test it doesn't add nil values for unspecified params during update
      with_params ["--id=1", "--new-name=host2"] do
        it_should_call_action_and_test_params(:update) do |par|
          nil_keys = par["host"].select { |key, value| value.nil? }
          nil_keys.empty?
        end
      end
    end

  end


  describe "SetParameterCommand" do

    before :each do
      ResourceMocks.parameters_index
    end

    let(:cmd) { HammerCLIForeman::Host::SetParameterCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name, value and host name", ["--name=name", "--value=val", "--host=name"]
      it_should_accept "name, value and host id", ["--name=name", "--value=val", "--host-id=1"]
      it_should_accept "name, value, type and host id", ["--name=name", "--parameter-type=integer", "--value=1", "--host-id=1"]
      it_should_fail_with "name missing", ["--value=val", "--host=name"]
      it_should_fail_with "value missing", ["--name=name", "--host=name"]
      # it_should_fail_with "host name or id missing", ["--name=name", "--value=val"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  describe "DeleteParameterCommand" do

    let(:cmd) { HammerCLIForeman::Host::DeleteParameterCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name and host name", ["--name=name", "--host=name"]
      it_should_accept "name and host id", ["--name=name", "--host-id=1"]
      # it_should_fail_with "name missing", ["--host=name"]
      # it_should_fail_with "host name or id missing", ["--name=name"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

  describe "StartCommand" do
    let(:cmd) { HammerCLIForeman::Host::StartCommand.new("", ctx) }
    describe "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "empty params", []
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end
  end

  describe "StopCommand" do
    let(:cmd) { HammerCLIForeman::Host::StopCommand.new("", ctx) }
    describe "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      it_should_accept "id and force", ["--id=1", "--force"]
      # it_should_failwith "empty params", []
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end
  end

  describe "RebootCommand" do
    let(:cmd) { HammerCLIForeman::Host::RebootCommand.new("", ctx) }
    describe "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "empty params", []
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end
  end

  describe "RebuildConfigCommand" do

    let(:cmd) { HammerCLIForeman::Host::RebuildConfigCommand.new("", ctx) }

    describe "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no arguments"
      # TODO: temporarily disabled, parameters are checked in the id resolver

    end
  end


  describe "DisassociateCommand" do
    let(:cmd) { HammerCLIForeman::Host::DisassociateCommand.new("", ctx) }
    describe "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
    end
  end
end
