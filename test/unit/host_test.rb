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
      it_should_print_columns ["Id", "Name", "Operating System", "Host Group", "IP", "MAC", "Global Status"]
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
        it_should_print_columns ["Host Group", "Compute Resource", "Compute Profile", "Puppet Environment"]
        it_should_print_columns ["Puppet CA Proxy", "Puppet Master Proxy", "Cert name"]
        it_should_print_columns ["Managed", "Status", "Installed at", "Last report"]
        it_should_print_columns ["Network", "Network interfaces", "Operating system", "Parameters", "All parameters",
                                 "Additional info"]
      end
    end
  end

  context "StatusCommand" do
    let(:cmd) { HammerCLIForeman::Host::StatusCommand.new("", ctx) }

    before :each do
      ResourceMocks.mock_action_call(:hosts, :power, { 'power' => 'running' })
      ResourceMocks.mock_action_call(:hosts, :get_status, { 'status_label' => 'No reports' })
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
          _(proc { cmd.run(with_params) }).must_output "#Status#Power#\n#No reports#running#\n"
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

  context "ConfigReportsCommand" do
    before do
      ResourceMocks.mock_action_call(:config_reports, :index, [])
    end

    let(:cmd) { HammerCLIForeman::Host::ConfigReportsCommand.new("", ctx) }

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

  context "SetParameterCommand" do
    before :each do
      ResourceMocks.parameters_index
    end

    let(:cmd) { HammerCLIForeman::Host::SetParameterCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, value and host name", ["--name=name", "--value=val", "--host=name"]
      it_should_accept "name, value and host id", ["--name=name", "--value=val", "--host-id=1"]
      it_should_accept "name, value, type and host id",
                       ["--name=name", "--parameter-type=integer", "--value=1", "--host-id=1"]
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

  context "RebuildConfigCommand" do
    let(:cmd) { HammerCLIForeman::Host::RebuildConfigCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      # it_should_fail_with "no arguments"
      # TODO: temporarily disabled, parameters are checked in the id resolver
    end
  end

  context "DisassociateCommand" do
    let(:cmd) { HammerCLIForeman::Host::DisassociateCommand.new("", ctx) }
    context "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
    end
  end
end
