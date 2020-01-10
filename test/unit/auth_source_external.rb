require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/auth_source'

describe HammerCLIForeman::AuthSourceExternal do

  include CommandTestHelper

  context 'ListCommand' do
    before :each do
      ResourceMocks.auth_source_external_index
    end

    let(:cmd) { HammerCLIForeman::AuthSourceExternal::ListCommand.new('', ctx) }

    context 'parameters' do
      it_should_accept 'no arguments'
      it_should_accept 'per page', ['--per-page=1']
      it_should_accept 'page', ['--page=2']
    end

    context 'output' do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records 1
      it_should_print_column 'Name'
      it_should_print_column 'Id'
    end
  end

  context 'UpdateCommand' do
    let(:cmd) { HammerCLIForeman::AuthSourceExternal::UpdateCommand.new('', ctx) }

    context 'parameters' do
      it_should_accept 'name', ['--name=External', '--new-name=auth-external-1']
      it_should_accept 'id', ['--id=11', '--new-name=auth-external-2']
    end
  end
end
