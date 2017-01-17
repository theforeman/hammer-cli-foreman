require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/host'

describe HammerCLIForeman::Host do

  include CommandTestHelper

  context "ListCommand" do
    before do
      ResourceMocks.mock_action_call(:hosts, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Host::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_columns ["Id", "Name", "Operating System", "Host Group", "IP", "MAC"]
    end

  end

  context "InfoCommand" do
    before do
      ResourceMocks.hosts_show
    end

    let(:cmd) { HammerCLIForeman::Host::InfoCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=host"]
      # it_should_fail_with "no arguments" # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_columns ["Id", "Name", "Organization", "Location"]
        it_should_print_columns ["Host Group", "Compute Resource", "Compute Profile", "Environment"]
        it_should_print_columns ["Puppet CA Id", "Puppet Master Id", "Cert name"]
        it_should_print_columns ["Managed", "Installed at", "Last report"]
        it_should_print_columns ["Network", "Network interfaces", "Operating system", "Parameters", "Additional info"]
      end
    end

  end

  context "StatusCommand" do

    let(:cmd) { HammerCLIForeman::Host::StatusCommand.new("", ctx) }

    before :each do
      ResourceMocks.mock_action_call(:hosts, :power, { 'power' => 'running' } )
      ResourceMocks.mock_action_call(:hosts, :status, { 'status' => 'No reports' } )
    end

    context "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no arguments"
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_columns ["Status", "Power"]

        it "should output status" do
          cmd.stubs(:context).returns(ctx.update(:adapter => :test))
          proc { cmd.run(with_params) }.must_output "#Status#Power#\n#No reports#running#\n"
        end
      end
    end

  end

  context "FactsCommand" do

    let(:cmd) { HammerCLIForeman::Host::FactsCommand.new("", ctx) }

    before(:each) do
      ResourceMocks.facts_index
    end

    context "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no arguments"
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do
      with_params ["--name=my5name.mydomain.net"] do
        it_should_print_column "Fact"
        it_should_print_column "Value"
      end
    end
  end


  context "PuppetClassesCommand" do
    before do
      ResourceMocks.mock_action_call(:puppetclasses, :index, {})
    end

    let(:cmd) { HammerCLIForeman::Host::PuppetClassesCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "host", ["--host=name=my5name.mydomain.net"]
      it_should_accept "host-id", ["--host-id=1"]
      # it_should_fail_with "host or host-id missing", []
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

    context "output" do

      with_params ["--host=my5name.mydomain.net"] do
        it_should_print_column "Id"
        it_should_print_column "Name"
      end
    end

  end


  context "PuppetRunCommand" do

    let(:cmd) { HammerCLIForeman::Host::PuppetRunCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no arguments"
      # TODO: temporarily disabled, parameters are checked in the id resolver

    end

    context "output" do
      with_params ["--id=1"] do
        it "should inform that puppet was triggered" do
          cmd.stubs(:context).returns(ctx.update(:adapter => :test))
          proc { cmd.run(with_params) }.must_output "Puppet run triggered\n"
        end
      end
    end
  end


  context "ReportsCommand" do
    before do
      ResourceMocks.mock_action_call(:reports, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Host::ReportsCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=my.test.host.org"]
    end

    context "output" do
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

  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Host::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "name or id missing", []
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Host::CreateCommand.new("", ctx) }

    before :each do
      HammerCLIForeman::Hosts::CommonUpdateOptions.stubs(:ask_password).returns("password")
    end

    context "parameters" do
      it_should_accept "name, environment_id, architecture_id, domain_id, puppet_proxy_id, operatingsystem_id and more",
          ["--name=host", "--environment-id=1", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1",
            "--ip=1.2.3.4", "--mac=11:22:33:44:55:66", "--medium-id=1", "--partition-table-id=1", "--subnet-id=1",
            "--model-id=1", "--hostgroup-id=1", "--owner-id=1", '--puppet-ca-proxy-id=1', '--puppet-class-ids',
            "--root-password=pwd", "--ask-root-password=true", "--provision-method=build", "--interface=primary=true,provision=true"]
      it_should_fail_with "name or id missing",
          ["--environment-id=1", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1", "--interface=primary=true,provision=true"]
      it_should_fail_with "environment_id missing",
          ["--name=host", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1", "--interface=primary=true,provision=true"]
      it_should_fail_with "architecture_id missing",
          ["--name=host", "--environment-id=1", "--domain-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1", "--interface=primary=true,provision=true"]
      it_should_fail_with "domain_id missing",
          ["--name=host", "--environment-id=1", "--architecture-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1", "--interface=primary=true,provision=true"]
      it_should_fail_with "puppet_proxy_id missing",
          ["--name=host", "--environment-id=1", "--architecture-id=1", "--domain-id=1", "--operatingsystem-id=1", "--interface=primary=true,provision=true"]
      it_should_fail_with "operatingsystem_id missing",
          ["--name=host", "--environment-id=1", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1", "--interface=primary=true,provision=true"]
      it_should_accept "only hostgroup name", ["--hostgroup=example", "--name=host", "--interface=primary=true,provision=true"]
      it_should_accept "only hostgroup ID", ["--hostgroup-id=1", "--name=host", "--interface=primary=true,provision=true"]

      with_params ["--name=host", "--environment-id=1", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1",
            "--ip=1.2.3.4", "--mac=11:22:33:44:55:66", "--medium-id=1", "--partition-table-id=1", "--subnet-id=1",
            "--model-id=1", "--hostgroup-id=1", "--owner-id=1", '--puppet-ca-proxy-id=1', '--puppet-class-ids',
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

  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Host::UpdateCommand.new("", ctx) }

    before :each do
      HammerCLIForeman::Hosts::CommonUpdateOptions.stubs(:ask_password).returns("password")
    end

    context "parameters" do
      it_should_accept "name", ["--name=host", "--new-name=host2"]
      it_should_accept "id and more", ["--id=1", "--new-name=host2", "--environment-id=1", "--architecture-id=1",
            "--domain-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1",
            "--ip=1.2.3.4", "--mac=11:22:33:44:55:66", "--medium-id=1", "--partition-table-id=1", "--subnet-id=1",
            "--model-id=1", "--hostgroup-id=1", "--owner-id=1", '--puppet-ca-proxy-id=1',
            "--root-password=pwd", "--ask-root-password=true", "--provision-method=build"]
      # it_should_fail_with "no params", []
      # it_should_fail_with "name or id missing", ["--new-name=host2"]
      # TODO: temporarily disabled, parameters are checked in the id resolver

      with_params ["--id=1", "--puppet-proxy-id=1"] do
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


  context "SetParameterCommand" do

    before :each do
      ResourceMocks.parameters_index
    end

    let(:cmd) { HammerCLIForeman::Host::SetParameterCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, value and host name", ["--name=name", "--value=val", "--host=name"]
      it_should_accept "name, value and host id", ["--name=name", "--value=val", "--host-id=1"]
      it_should_fail_with "name missing", ["--value=val", "--host=name"]
      it_should_fail_with "value missing", ["--name=name", "--host=name"]
      # it_should_fail_with "host name or id missing", ["--name=name", "--value=val"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end


  context "DeleteParameterCommand" do

    let(:cmd) { HammerCLIForeman::Host::DeleteParameterCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name and host name", ["--name=name", "--host=name"]
      it_should_accept "name and host id", ["--name=name", "--host-id=1"]
      # it_should_fail_with "name missing", ["--host=name"]
      # it_should_fail_with "host name or id missing", ["--name=name"]
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

  context "StartCommand" do
    let(:cmd) { HammerCLIForeman::Host::StartCommand.new("", ctx) }
    context "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "empty params", []
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end
  end

  context "StopCommand" do
    let(:cmd) { HammerCLIForeman::Host::StopCommand.new("", ctx) }
    context "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      it_should_accept "id and force", ["--id=1", "--force"]
      # it_should_failwith "empty params", []
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end
  end

  context "RebootCommand" do
    let(:cmd) { HammerCLIForeman::Host::RebootCommand.new("", ctx) }
    context "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "empty params", []
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end
  end

  context "SCParamsCommand" do

    before :each do
      ResourceMocks.smart_class_parameters_index
    end

    let(:cmd) { HammerCLIForeman::Host::SCParamsCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "host", ["--host=host"]
      it_should_accept "host-id", ["--host-id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

  context "SmartVariablesCommand" do

    before :each do
      ResourceMocks.smart_variables_index
    end

    let(:cmd) { HammerCLIForeman::Host::SmartVariablesCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "host", ["--host=host"]
      it_should_accept "host-id", ["--host-id=1"]
      # it_should_fail_with "name or id missing", [] # TODO: temporarily disabled, parameters are checked in the id resolver
    end

  end

  context "RebuildConfigCommand" do

    let(:cmd) { HammerCLIForeman::Host::RebuildConfigCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no arguments"
      # TODO: temporarily disabled, parameters are checked in the id resolver

    end
  end
end
