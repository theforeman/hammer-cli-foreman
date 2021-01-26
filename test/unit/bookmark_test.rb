# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/bookmark'

describe HammerCLIForeman::Bookmark do
  include CommandTestHelper

  context 'ListCommand' do
    before :each do
      ResourceMocks.bookmarks
    end

    let(:cmd) { HammerCLIForeman::Bookmark::ListCommand.new('', ctx) }

    context 'parameters' do
      it_should_accept 'no arguments'
      it_should_fail_with 'organization param', ['--organization-id=1']
      it_should_fail_with 'location param', ['--location-id=1']
    end

    context 'output' do
      let(:expected_record_count) { count_records(cmd.resource.call(:index)) }

      it_should_print_n_records
      it_should_print_column 'Id'
      it_should_print_column 'Name'
      it_should_print_column 'Controller'
      it_should_print_column 'Search Query'
      it_should_print_column 'Public'
      it_should_print_column 'Owner Id'
      it_should_print_column 'Owner Type'
    end
  end

  context 'InfoCommand' do
    let(:cmd) { HammerCLIForeman::Bookmark::InfoCommand.new('', ctx) }

    context 'parameters' do
      it_should_accept 'id', ['--id=1']
      it_should_accept 'name', ['--name=active']
      it_should_fail_with 'organization param', ['--organization-id=1']
      it_should_fail_with 'location param', ['--location-id=1']
    end

    context 'output' do
      with_params ['--id=1'] do
        it_should_print_n_records 1
        it_should_print_column 'Id'
        it_should_print_column 'Name'
        it_should_print_column 'Controller'
        it_should_print_column 'Search Query'
        it_should_print_column 'Public'
        it_should_print_column 'Owner Id'
        it_should_print_column 'Owner Type'
      end
    end
  end

  context 'CreateCommand' do
    let(:cmd) { HammerCLIForeman::Bookmark::CreateCommand.new('', ctx) }

    context 'parameters' do
      it_should_accept 'name, public, controller, query',
                       ['--name=active', '--public=1', '--controller=hosts',
                        '--query=last_report > "35 minutes ago" and (status.applied > 0 or status.restarted > 0)']
      it_should_fail_with 'organization param', ['--organization-id=1']
      it_should_fail_with 'location param', ['--location-id=1']
    end

  end

  context 'DeleteCommand' do
    let(:cmd) { HammerCLIForeman::Bookmark::DeleteCommand.new('', ctx) }

    context 'parameters' do
      it_should_accept 'id', ['--id=1']
      it_should_accept 'name', ['--name=active']
      it_should_fail_with 'organization param', ['--organization-id=1']
      it_should_fail_with 'location param', ['--location-id=1']
    end
  end

  context 'UpdateCommand' do
    let(:cmd) { HammerCLIForeman::Bookmark::UpdateCommand.new('', ctx) }

    context 'parameters' do
      it_should_accept 'id', ['--id=1']
      it_should_accept 'name', ['--name=active']
      it_should_accept 'name, public, controller, query',
                       ['--name=active', '--public=1', '--controller=hosts',
                        '--query=last_report > "35 minutes ago" and (status.applied > 0 or status.restarted > 0)']
      it_should_fail_with 'organization param', ['--organization-id=1']
      it_should_fail_with 'location param', ['--location-id=1']
    end
  end
end
