require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::Hostgroup do

  extend CommandTestHelper

  before :each do
    HammerCLI::Connection.drop_all
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource.resource_class)
    cmd.stubs(:name_to_id).returns(1)
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::ListCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "no arguments"
      it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.call(:index)[0].length }

      it_should_print_n_records
      it_should_print_columns ["Id", "Name", "Label", "Operating System Id", "Subnet Id"]
      it_should_print_columns ["Domain Id", "Environment Id", "Puppetclass Ids", "Ancestry"]
      it_should_print_columns ["Architecture Id", "Partition Table Id", "Medium Id"]
      it_should_print_columns ["Puppet CA Proxy Id", "Puppet Master Proxy Id"]
    end

  end

  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::InfoCommand.new("", ctx) }

    before :each do
      HammerCLIForeman::Parameter.stubs(:get_parameters).returns([])
    end

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "no arguments"
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_columns ["Id", "Name", "Label", "Operating System Id", "Subnet Id"]
        it_should_print_columns ["Domain Id", "Environment Id", "Puppetclass Ids", "Ancestry"]
        it_should_print_columns ["Parameters"]
      end
    end

  end

  context "DeleteCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::DeleteCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "id missing", []
    end

  end

  context "CreateCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::CreateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, parent_id, environment_id, architecture_id, domain_id, puppet_proxy_id, operatingsystem_id and more",
          ["--name=hostgroup", "--parent-id=1", "--environment-id=1", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1",
            "--operatingsystem-id=1", "--medium-id=1", "--ptable-id=1", "--subnet-id=1", '--puppet-ca-proxy-id=1', '--puppetclass-ids=1,2']
      it_should_fail_with "name or id missing",
          ["--environment-id=1", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1", "--operatingsystem-id=1"]
    end
  end

  context "UpdateCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::UpdateCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, parent_id, environment_id, architecture_id, domain_id, puppet_proxy_id, operatingsystem_id and more",
          ["--id=1 --name=hostgroup2", "--parent-id=1", "--environment-id=1", "--architecture-id=1", "--domain-id=1", "--puppet-proxy-id=1",
            "--operatingsystem-id=1", "--medium-id=1", "--ptable-id=1", "--subnet-id=1", '--puppet-ca-proxy-id=1', '--puppetclass-ids=1,2']
      it_should_fail_with "no params", []
      it_should_fail_with "id missing", ["--name=host2"]
    end

  end


  context "SetParameterCommand" do

    before :each do
      resource_mock = ApipieResourceMock.new(cmd.class.resource.resource_class)
      resource_mock.stub_method(:index, [])
      cmd.class.resource resource_mock
    end

    let(:cmd) { HammerCLIForeman::Hostgroup::SetParameterCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name, value and hostgroup id", ["--name=name", "--value=val", "--hostgroup-id=id"]
      it_should_fail_with "name missing", ["--value=val", "--hostgroup-id=1"]
      it_should_fail_with "value missing", ["--name=name", "--hostgroup-id=1"]
      it_should_fail_with "hostgroup id missing", ["--name=name", "--value=val"]
    end

  end


  context "DeleteParameterCommand" do

    let(:cmd) { HammerCLIForeman::Hostgroup::DeleteParameterCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name and hostgroup id", ["--name=name", "--hostgroup-id=id"]
      it_should_fail_with "name missing", ["--hostgroup-id=id"]
      it_should_fail_with "hostgroup id missing", ["--name=name"]
    end

  end


  context "SCParamsCommand" do

    before :each do
      cmd.class.resource ResourceMocks.smart_class_parameter
    end

    let(:cmd) { HammerCLIForeman::Hostgroup::SCParamsCommand.new("", ctx) }

    context "parameters" do
      it_should_accept "name", ["--name=env"]
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "name or id missing", []
    end

  end

end

