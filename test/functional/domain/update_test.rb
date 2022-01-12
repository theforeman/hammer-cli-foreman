require_relative '../test_helper'

describe 'Domain' do
  describe 'UpdateCommand' do
    let(:cmd) { %w[domain update] }
    let(:minimal_params) { %w[--id=1] }

    def domain_params(additional_params = {})
      params = {
        id: '1',
        domain: {}
      }
      params[:domain].merge!(additional_params)
      params
    end

    it 'should print error on missing --id' do
      expected_result = missing_args_error_result(cmd, '--id')

      api_expects_no_call

      result = run_cmd(cmd)
      assert_cmd(expected_result, result)
    end

    it 'allows minimal options' do
      api_expects(:domains, :update).with_params(domain_params)

      run_cmd(cmd + minimal_params)
    end

    it 'allows description' do
      params = %w[--description=shortdesc]
      api_expects(:domains, :update).with_params(domain_params(fullname: 'shortdesc'))

      run_cmd(cmd + minimal_params + params)
    end

    it 'allows dns id' do
      params = %w[--dns-id=1]
      api_expects(:domains, :update).with_params(domain_params(dns_id: 1))

      run_cmd(cmd + minimal_params + params)
    end

    it 'allows dns name' do
      params = %w[--dns=sp1]
      api_expects_search(:smart_proxies, { name: 'sp1' }).returns(
        index_response([{ 'id' => 1 }])
      )
      api_expects(:domains, :update).with_params(domain_params(dns_id: 1))

      run_cmd(cmd + minimal_params + params)
    end

    it 'allows location ids' do
      params = %w[--location-ids=1,4]
      api_expects(:domains, :update).with_params(domain_params(location_ids: %w[1 4]))

      run_cmd(cmd + minimal_params + params)
    end

    it 'allows location names' do
      params = %w[--locations=loc1,loc2]
      api_expects(:locations, :index) do |p|
        p[:search] == 'name = "loc1" or name = "loc2"'
      end.returns(index_response([{ 'id' => 1 }, { 'id' => 2 }]))
      api_expects(:domains, :update).with_params(domain_params(location_ids: [1, 2]))

      run_cmd(cmd + minimal_params + params)
    end

    it 'allows organization ids' do
      params = %w[--organization-ids=1,4]
      api_expects(:domains, :update).with_params(domain_params(organization_ids: %w[1 4]))

      run_cmd(cmd + minimal_params + params)
    end

    it 'allows organization names' do
      params = %w[--organizations=org1,org2]
      api_expects(:organizations, :index) do |p|
        p[:search] == 'name = "org1" or name = "org2"'
      end.returns(index_response([{ 'id' => 1 }, { 'id' => 2 }]))
      api_expects(:domains, :update).with_params(domain_params(organization_ids: [1, 2]))

      run_cmd(cmd + minimal_params + params)
    end
  end
end
