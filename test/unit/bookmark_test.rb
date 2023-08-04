# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/bookmark'

describe HammerCLIForeman::Bookmark do
  include CommandTestHelper

  describe 'ListCommand' do
    before :each do
      ResourceMocks.bookmarks
    end

    let(:cmd) { HammerCLIForeman::Bookmark::ListCommand.new('', ctx) }

    describe 'parameters' do
      it_should_accept 'no arguments'
      it_should_accept 'organization', ['--organization-id=1']
      it_should_accept 'location', ['--location-id=1']
    end

    describe 'output' do
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

  describe 'InfoCommand' do
    let(:cmd) { HammerCLIForeman::Bookmark::InfoCommand.new('', ctx) }

    describe 'parameters' do
      it_should_accept 'id', ['--id=1']
      it_should_accept 'name', ['--name=active']
      it_should_accept 'organization', %w[--id=1 --organization-id=1]
      it_should_accept 'location', %w[--id=1 --location-id=1]
    end

    describe 'output' do
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

  describe 'CreateCommand' do
    let(:cmd) { HammerCLIForeman::Bookmark::CreateCommand.new('', ctx) }

    describe 'parameters' do
      it_should_accept 'name, public, controller, query, organization, location',
                       ['--name=active', '--public=1', '--controller=hosts', '--organization-id=1', '--location-id=1',
                        '--query=last_report > "35 minutes ago" and (status.applied > 0 or status.restarted > 0)']
    end

  end

  describe 'DeleteCommand' do
    let(:cmd) { HammerCLIForeman::Bookmark::DeleteCommand.new('', ctx) }

    describe 'parameters' do
      it_should_accept 'id', ['--id=1']
      it_should_accept 'name', ['--name=active']
      it_should_accept 'organization', %w[--id=1 --organization-id=1]
      it_should_accept 'location', %w[--id=1 --location-id=1]
    end
  end

  describe 'UpdateCommand' do
    let(:cmd) { HammerCLIForeman::Bookmark::UpdateCommand.new('', ctx) }

    describe 'parameters' do
      it_should_accept 'id', ['--id=1']
      it_should_accept 'name', ['--name=active']
      it_should_accept 'name, public, controller, query, organization, location',
                       ['--name=active', '--public=1', '--controller=hosts', '--organization-id=1', '--location-id=1',
                        '--query=last_report > "35 minutes ago" and (status.applied > 0 or status.restarted > 0)']
    end
  end
end
