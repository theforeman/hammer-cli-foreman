require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')


describe HammerCLIForeman::PuppetClass do

  extend CommandTestHelper

  before :each do
    cmd.output.adapter = HammerCLI::Output::Adapter::Silent.new
    cmd.class.resource ApipieResourceMock.new(cmd.class.resource.resource_class)
  end

  context "ListCommand" do

    let(:cmd) { HammerCLIForeman::PuppetClass::ListCommand.new("") }

    context "parameters" do
      it_should_accept "no arguments"
      # FIXME: the command should accept search parameters in future
      # it_should_accept_search_params
    end

    context "output" do
      let(:expected_record_count) { cmd.resource.call(:index)[0].length }

      it_should_print_n_records
      it_should_print_column "Id"
      it_should_print_column "Name"
    end

  end


  context "InfoCommand" do

    let(:cmd) { HammerCLIForeman::PuppetClass::InfoCommand.new("") }

    context "parameters" do
      it_should_accept "id", ["--id=1"]
      it_should_fail_with "no arguments"
    end

    context "output" do
      with_params ["--id=1"] do
        it_should_print_n_records 1
        it_should_print_column "Id"
        it_should_print_column "Name"
        it_should_print_column "Smart variables"
      end
    end

  end



end
