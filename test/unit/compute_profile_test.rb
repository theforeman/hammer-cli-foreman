# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')

require 'hammer_cli_foreman/compute_profile'

describe HammerCLIForeman::ComputeProfile do
  include CommandTestHelper

  describe 'ListCommand' do
    before :each do
      ResourceMocks.compute_profiles
    end

    let(:cmd) { HammerCLIForeman::ComputeProfile::ListCommand.new('', ctx) }

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
    end
  end

  describe 'InfoCommand' do
    let(:cmd) { HammerCLIForeman::ComputeProfile::InfoCommand.new('', ctx) }

    describe 'parameters' do
      it_should_accept 'id', ['--id=1']
      it_should_accept 'name', ['--name=test']
      it_should_accept 'organization', %w[--id=1 --organization-id=1]
      it_should_accept 'location', %w[--id=1 --location-id=1]
    end

    describe 'output' do
      with_params ['--id=1'] do
        it_should_print_n_records 1
        it_should_print_column 'Id'
        it_should_print_column 'Name'
        it_should_print_column 'Created at'
        it_should_print_column 'Updated at'
        it_should_print_column 'Compute attributes'
      end
    end
  end

  describe 'CreateCommand' do
    let(:cmd) { HammerCLIForeman::ComputeProfile::CreateCommand.new('', ctx) }

    describe 'parameters' do
      it_should_accept 'name', ['--name=test']
      it_should_accept 'organization', %w[--name=test --organization-id=1]
      it_should_accept 'location', %w[--name=test --location-id=1]
    end

  end

  describe 'DeleteCommand' do
    let(:cmd) { HammerCLIForeman::ComputeProfile::DeleteCommand.new('', ctx) }

    describe 'parameters' do
      it_should_accept 'id', ['--id=1']
      it_should_accept 'name', ['--name=test']
      it_should_accept 'organization', %w[--id=1 --organization-id=1]
      it_should_accept 'location', %w[--id=1 --location-id=1]
    end
  end

  describe 'UpdateCommand' do
    let(:cmd) { HammerCLIForeman::ComputeProfile::UpdateCommand.new('', ctx) }

    describe 'parameters' do
      it_should_accept 'id', ['--id=1']
      it_should_accept 'name', ['--name=test']
      it_should_accept 'organization', %w[--id=1 --organization-id=1]
      it_should_accept 'location', %w[--id=1 --location-id=1]
    end
  end
end
