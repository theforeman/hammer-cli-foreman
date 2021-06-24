# frozen_string_literal: true
require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/config_group'

describe HammerCLIForeman::ConfigGroup do
  include CommandTestHelper

  context 'ListCommand' do
    let(:cmd) { HammerCLIForeman::ConfigGroup::ListCommand.new('', ctx) }

    before :each do
      ResourceMocks.config_groups_index
    end

    context 'parameters' do
      it_should_accept 'no arguments'
      it_should_accept_search_params
      it_should_accept 'organization', ['--organization-id=1']
      it_should_accept 'location', ['--location-id=1']
    end

    context 'output' do
      let(:expected_record_count) { cmd.resource.call(:index).length }
      it_should_print_n_records
      it_should_print_columns %w[ID Name]
    end
  end

  context 'InfoCommand' do
    let(:cmd) { HammerCLIForeman::ConfigGroup::InfoCommand.new('', ctx) }

    context 'parameters' do
      it_should_accept 'id', ['--id=1']
      it_should_accept 'name', ['--name=group_x']
      it_should_accept 'organization', %w[--id=1 --organization-id=1]
      it_should_accept 'location', %w[--id=1 --location-id=1]
    end

    context 'output' do
      with_params ['--id=1'] do
        it_should_print_n_records 1
        it_should_print_column 'Name'
        it_should_print_column 'ID'
        it_should_print_column 'Puppetclasses'
      end
    end
  end

  context 'CreateCommand' do
    let(:cmd) { HammerCLIForeman::ConfigGroup::CreateCommand.new('', ctx) }

    context 'parameters' do
      it_should_accept 'name, puppetclass ids, location, organization',
                       %w[--name=first_group --puppet-class-ids=1,2 --location-id=1 --organization-id=1]
    end
  end

  context 'DeleteCommand' do
    let(:cmd) { HammerCLIForeman::ConfigGroup::DeleteCommand.new('', ctx) }

    context 'parameters' do
      it_should_accept 'name', ['--name=group_x']
      it_should_accept 'id', ['--id=1']
      it_should_accept 'organization', %w[--id=1 --organization-id=1]
      it_should_accept 'location', %w[--id=1 --location-id=1]
    end
  end

  context 'UpdateCommand' do

    let(:cmd) { HammerCLIForeman::ConfigGroup::UpdateCommand.new('', ctx) }

    context 'parameters' do
      it_should_accept 'name', ['--name=group_x']
      it_should_accept 'id', ['--id=1']
      it_should_accept 'organization', %w[--id=1 --organization-id=1]
      it_should_accept 'location', %w[--id=1 --location-id=1]
    end
  end
end
