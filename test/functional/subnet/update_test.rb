require_relative '../test_helper'
require 'hammer_cli_foreman/subnet'

module HammerCLIForeman
  describe Subnet do
    describe UpdateCommand do
      def subnet_params(additional_params = {})
        params = {
          :id => 1,
          :subnet => {}
        }
        params[:subnet].merge!(additional_params)
        params
      end

      it 'allows minimal options' do
        api_expects(:subnets, :update) do |par|
          par['id'] == 1
        end
        run_cmd(%w(subnet update --id 1))
      end

      it 'allows dhcp id' do
        api_expects(:subnets, :update).with_params(subnet_params(:dhcp_id => 1))
        run_cmd(%w(subnet update --id 1 --dhcp-id 1))
      end

      it 'allows dhcp name' do
        api_expects_search(:smart_proxies, { :name => 'sp1' })
        .returns(index_response([{'id' => 1}]))
        api_expects(:subnets, :update).with_params(subnet_params(:dhcp_id => 1))
        run_cmd(%w(subnet update --id 1 --dhcp sp1))
      end

      it 'allows dns id' do
        api_expects(:subnets, :update).with_params(subnet_params(:dns_id => 1))
        run_cmd(%w(subnet update --id 1 --dns-id 1))
      end

      it 'allows dns name' do
        api_expects_search(:smart_proxies, { :name => 'sp1' })
        .returns(index_response([{'id' => 1}]))
        api_expects(:subnets, :update).with_params(subnet_params(:dns_id => 1))
        run_cmd(%w(subnet update --id 1 --dns sp1))
      end

      it 'allows tftp id' do
        api_expects(:subnets, :update).with_params(subnet_params(:tftp_id => 1))
        run_cmd(%w(subnet update --id 1 --tftp-id 1))
      end

      it 'allows tftp name' do
        api_expects_search(:smart_proxies, { :name => 'sp1' })
        .returns(index_response([{'id' => 1}]))
        api_expects(:subnets, :update).with_params(subnet_params(:tftp_id => 1))
        run_cmd(%w(subnet update --id 1 --tftp sp1))
      end

      it 'allows domain ids' do
        api_expects(:subnets, :update).with_params(subnet_params(:domain_ids => ['1', '4']))
        run_cmd(%w(subnet update --id 1 --domain-ids 1,4))
      end

      it 'allows domain names' do
        api_expects(:domains, :index) do |p|
          p[:search] == "name = \"d1\" or name = \"d2\""
        end.returns(index_response([{'id' => 1}, {'id' => 2}]))
        api_expects(:subnets, :update).with_params(subnet_params(:domain_ids => [1, 2]))
        run_cmd(%w(subnet update --id 1 --domains d1,d2))
      end

      it 'allows location ids' do
        api_expects(:subnets, :update).with_params(subnet_params(:location_ids => ['1', '4']))
        run_cmd(%w(subnet update --id 1 --location-ids 1,4))
      end

      it 'allows location names' do
        api_expects(:locations, :index) do |p|
          p[:search] == "name = \"loc1\" or name = \"loc2\""
        end.returns(index_response([{'id' => 1}, {'id' => 2}]))
        api_expects(:subnets, :update).with_params(subnet_params(:location_ids => [1, 2]))
        run_cmd(%w(subnet update --id 1 --locations loc1,loc2))
      end

      it 'allows organization ids' do
        api_expects(:subnets, :update).with_params(subnet_params(:organization_ids => ['1', '4']))
        run_cmd(%w(subnet update --id 1 --organization-ids 1,4))
      end

      it 'allows organization names' do
        api_expects(:organizations, :index) do |p|
          p[:search] == "name = \"org1\" or name = \"org2\""
        end.returns(index_response([{'id' => 1}, {'id' => 2}]))
        api_expects(:subnets, :update).with_params(subnet_params(:organization_ids => [1, 2]))
        run_cmd(%w(subnet update --id 1 --organizations org1,org2))
      end

      it 'allows primary dns' do
        api_expects(:subnets, :update).with_params(subnet_params(:dns_primary => '192.168.122.2'))
        run_cmd(%w(subnet update --id 1 --dns-primary 192.168.122.2))
      end

      it 'allows secondary dns' do
        api_expects(:subnets, :update).with_params(subnet_params(:dns_secondary => '192.168.122.2'))
        run_cmd(%w(subnet update --id 1 --dns-secondary 192.168.122.2))
      end

      it 'allows ip address range FROM' do
        api_expects(:subnets, :update).with_params(subnet_params(:from => '192.168.122.3'))
        run_cmd(%w(subnet update --id 1 --from 192.168.122.3))
      end

      it 'allows ip address range TO' do
        api_expects(:subnets, :update).with_params(subnet_params(:to => '192.168.122.60'))
        run_cmd(%w(subnet update --id 1 --to 192.168.122.60))
      end

      it 'allows gateway' do
        api_expects(:subnets, :update).with_params(subnet_params(:gateway => '192.168.122.1'))
        run_cmd(%w(subnet update --id 1 --gateway 192.168.122.1))
      end

      it 'allows network type' do
        api_expects(:subnets, :update).with_params(subnet_params(:network_type => 'IPv4'))
        run_cmd(%w(subnet update --id 1 --network-type IPv4))
      end

    end
  end
end
