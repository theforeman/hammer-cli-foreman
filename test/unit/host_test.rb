require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::Host do

  extend CommandTestHelper

  before :each do
    cmd.output.adapter = HammerCLI::Output::Adapter::Silent.new
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource)
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::Host::ListCommand.new("") }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.index[0].length }

      it_should_print_n_records
      it_should_print_columns ["Id", "Name", "Operating System Id", "Host Group Id", "IP", "MAC"]
    end

  end

  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Host::InfoCommand.new("") }

    before :each do
      HammerCLIForeman::Parameter.stubs(:get_parameters).returns([])
    end

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_accept "name", ["--name=host"]
      it_should_fail_with "no arguments"
    end

    context "output" do
      let(:with_params) { ["--id=1"] }
      it_should_print_n_records 1
      it_should_print_columns ["Id", "Name", "Operating System Id", "Host Group Id", "IP", "MAC"]

      it_should_print_columns ["UUID", "Cert name"]
      it_should_print_columns ["Environment", "Environment Id"]
      it_should_print_columns ["Managed", "Enabled", "Build"]
      it_should_print_columns ["Use image", "Disk", "Image file"]
      it_should_print_columns ["SP Name", "SP IP", "SP MAC", "SP Subnet", "SP Subnet Id"]
      it_should_print_columns ["Created at", "Updated at", "Installed at", "Last report"]
      it_should_print_columns ["Puppet CA Proxy Id", "Medium Id", "Model Id", "Owner Id", "Subnet Id", "Domain Id"]
      it_should_print_columns ["Puppet Proxy Id", "Owner Type", "Partition Table Id", "Architecture Id", "Image Id", "Compute Resource Id"]
      it_should_print_columns ["Comment"]
    end

  end

  context "StatusCommand" do

    let(:cmd) { HammerCLIForeman::Host::StatusCommand.new("") }

    context "output" do
      let(:with_params) { ["--id=1"] }

      it "should output status" do
        cmd.output.adapter = TestAdapter.new
        proc { cmd.run(with_params) }.must_output "missing\n"
      end
    end

  end

  context "PuppetRunCommand" do

    let(:cmd) { HammerCLIForeman::Host::PuppetRunCommand.new("") }

    context "output" do
      let(:with_params) { ["--id=1"] }
      it "should inform that puppet was triggered" do 
        cmd.output.adapter = TestAdapter.new
        proc { cmd.run(with_params) }.must_output "Puppet run triggered\n"
      end
    end
  end

   context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Host::DeleteCommand.new("") }

    context "parameters" do
      it_should_accept "name", ["--name=host"]
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "name or id missing", []
    end

  end

  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Host::CreateCommand.new("") }

    context "parameters" do
      it_should_accept "name, environment_id, architecture_id, domain_id, puppet_proxy_id, operatingsystem_id and more", 
          ["--name=host", "--environment-id=1", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1",
            "--ip=1.2.3.4", "--mac=11:22:33:44:55:66", "--medium-id=1", "--ptable-id=1", "--subnet-id=1", 
            "--sp-subnet-id=1", "--model-id-id=1", "--hostgroup-id=1", "--owner-id=1", '--puppet-ca-proxy-id=1',
            "--image-id=1"]
      it_should_fail_with "name or id missing", 
          ["--environment-id=1", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1"]
      it_should_fail_with "environment_id missing", 
          ["--name=host", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1"]
      it_should_fail_with "architecture_id missing", 
          ["--name=host", "--environment-id=1", "--domain-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1"]
      it_should_fail_with "domain_id missing", 
          ["--name=host", "--environment-id=1", "--architecture-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1"]
      it_should_fail_with "puppet_proxy_id missing", 
          ["--name=host", "--environment-id=1", "--architecture-id=1", "--domain-id=1", "--operatingsystem-id=1"]
      it_should_fail_with "operatingsystem_id missing", 
          ["--name=host", "--environment-id=1", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1"]
    end
  end

  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Host::UpdateCommand.new("") }

    context "parameters" do
      it_should_accept "name", ["--name=host", "--new-name=host2"]
      it_should_accept "id and more", ["--id=1", "--new-name=host2", "--environment-id=1", "--architecture-id=1", 
            "--domain-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1",
            "--ip=1.2.3.4", "--mac=11:22:33:44:55:66", "--medium-id=1", "--ptable-id=1", "--subnet-id=1", 
            "--sp-subnet-id=1", "--model-id-id=1", "--hostgroup-id=1", "--owner-id=1", '--puppet-ca-proxy-id=1',
            "--image-id=1"]
      it_should_fail_with "no params", []
      it_should_fail_with "name or id missing", ["--new-name=host2"]
    end

  end


  context "SetParameterCommand" do

    before :each do
      cmd.class.resource.stubs(:index).returns([[],""])
    end

    let(:cmd) { HammerCLIForeman::Host::SetParameterCommand.new("") }

    context "parameters" do
      it_should_accept "name, value and host name", ["--name=name", "--value=val", "--host-name=name"]
      it_should_accept "name, value and host id", ["--name=name", "--value=val", "--host-id=id"]
      it_should_fail_with "name missing", ["--value=val", "--host-name=name"]
      it_should_fail_with "value missing", ["--name=name", "--host-name=name"]
      it_should_fail_with "host name or id missing", ["--name=name", "--value=val"]
    end

  end


  context "DeleteParameterCommand" do

    let(:cmd) { HammerCLIForeman::Host::DeleteParameterCommand.new("") }

    context "parameters" do
      it_should_accept "name and host name", ["--name=name", "--host-name=name"]
      it_should_accept "name and host id", ["--name=name", "--host-id=id"]
      it_should_fail_with "name missing", ["--host-name=name"]
      it_should_fail_with "host name or id missing", ["--name=name"]
    end

  end

end

