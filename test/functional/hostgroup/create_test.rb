require_relative '../test_helper'
require 'hammer_cli_foreman/hostgroup'

module HammerCLIForeman
  describe Hostgroup do
    describe CreateCommand do
      it 'allows minimal options' do
        api_expects(:hostgroups, :create) do |par|
          par['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1))
      end

      it 'allows architecture id' do
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['architecture_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --architecture-id 1))
      end

      it 'allows architecture name' do
        api_expects(:architectures, :index) do |p|
          p[:search] = "name = \"arch1\""
        end.returns(index_response([{'id' => 1}]))
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['architecture_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --architecture arch1))
      end

      it 'allows compute profile id' do
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['compute_profile_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --compute-profile-id 1))
      end

      it 'allows compute profile name' do
        api_expects(:compute_profiles, :index) do |p|
          p[:search] = "name = \"cp1\""
        end.returns(index_response([{'id' => 1}]))
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['compute_profile_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --compute-profile cp1))
      end

      it 'allows domain id' do
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['domain_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --domain-id 1))
      end

      it 'allows domain name' do
        api_expects(:domains, :index) do |p|
          p[:search] = "name = \"d1\""
        end.returns(index_response([{'id' => 1}]))
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['domain_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --domain d1))
      end

      it 'allows location ids' do
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['location_ids'] == ['1','4'] &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --location-ids 1,4))
      end

      it 'allows location names' do
        api_expects(:locations, :index) do |p|
          p[:search] == "name = \"loc1\" or name = \"loc2\""
        end.returns(index_response([{'id' => 1}, {'id' => 2}]))
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['location_ids'] == [1, 2] &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --locations loc1,loc2))
      end

      it 'allows medium id' do
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['medium_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --medium-id 1))
      end

      it 'allows medium name' do
        api_expects(:media, :index) do |p|
          p[:search] = "name = \"med1\""
        end.returns(index_response([{'id' => 1}]))
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['medium_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --medium med1))
      end

      it 'allows operating system id' do
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['operatingsystem_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --operatingsystem-id 1))
      end

      it 'allows operating system name' do
        api_expects(:operatingsystems, :index) do |p|
          p[:search] = "name = \"os1\""
        end.returns(index_response([{'id' => 1}]))
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['operatingsystem_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --operatingsystem os1))
      end

      it 'allows organization ids' do
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['organization_ids'] == ['1','4'] &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --organization-ids 1,4))
      end

      it 'allows organization names' do
        api_expects(:organizations, :index) do |p|
          p[:search] == "name = \"org1\" or name = \"org2\""
        end.returns(index_response([{'id' => 1}, {'id' => 2}]))
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['organization_ids'] == [1, 2] &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --organizations org1,org2))
      end

      it 'allows parent hostgroup id' do
        api_expects(:hostgroups, :create).with_params({
          :hostgroup => {
            :name => 'hg1',
            :parent_id => 1
          }
        })
        run_cmd(%w(hostgroup create --name hg1 --parent-id 1))
      end

      it 'allows parent hostgroup name' do
        api_expects(:hostgroups, :index) do |p|
          p[:search] = "name = \"parent_hg\""
        end.returns(index_response([{'id' => 1}]))
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['parent_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --parent parent_hg))
      end

      it 'allows parent hostgroup title' do
        api_expects(:hostgroups, :index) do |p|
          p[:search] = 'title = "parent_hg"'
        end.returns(index_response([{ 'id' => 1 }]))
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['parent_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w[hostgroup create --name hg1 --parent parent_hg])
      end

      it 'allows partition table id' do
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['ptable_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --partition-table-id 1))
      end

      it 'allows partition table name' do
        api_expects(:ptables, :index) do |p|
          p[:search] = "name = \"pt1\""
        end.returns(index_response([{'id' => 1}]))
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['ptable_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --partition-table pt1))
      end

      it 'allows realm id' do
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['realm_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --realm-id 1))
      end

      it 'allows realm name' do
        api_expects(:realms, :index) do |p|
          p[:search] = "name = \"realm1\""
        end.returns(index_response([{'id' => 1}]))
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['realm_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --realm realm1))
      end

      it 'allows subnet id' do
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['subnet_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --subnet-id 1))
      end

      it 'allows subnet name' do
        api_expects(:subnets, :index) do |p|
          p[:search] = "name = \"subnet1\""
        end.returns(index_response([{'id' => 1}]))
        api_expects(:hostgroups, :create) do |p|
          p['hostgroup']['subnet_id'] == 1 &&
            p['hostgroup']['name'] == 'hg1'
        end
        run_cmd(%w(hostgroup create --name hg1 --subnet subnet1))
      end
    end
  end
end
