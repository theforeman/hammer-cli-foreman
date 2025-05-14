
require File.join(File.dirname(__FILE__), 'test_helper')

require 'hammer_cli_foreman/compute_resource'

describe HammerCLIForeman::VirtualMachine do

  describe "InfoCommand" do
    before do
      @cmd = ["compute-resource", "virtual-machine", "info"]
      @vm = {
          'id' => 1,
          'name' => 'vm1',
          'provider' => 'Libvirt',
      }
    end

    it "should print error on missing --id and --vm-id" do
      api_expects_no_call
      result = run_cmd(@cmd)
      assert_match("Missing arguments for '--id', '--vm-id'.\n", result.err)
    end

    it "should print error on missing --vm-id" do
      params = ['--id=1']

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_match("Missing arguments for '--vm-id'.\n", result.err)
    end

    it "should return vm info" do
      params = ['--id=1', '--vm-id=1']
      api_expects(:compute_resources, :show_vm) do |par|
        par['id'] == '1' && par['vm_id'] == '1'
      end.returns(@vm)
      result = run_cmd(@cmd + params)
      assert_match("Id:   1\nName: vm1\n\n", result.out)
    end

  end

  describe "ListCommand" do
    before do
      @cmd = ["compute-resource", "virtual-machines"]
      @available_virtual_machines = [
        { id: 1, name: 'vm1' },
        { id: 2, name: 'vm2' }
      ]
    end

    it "should print error on missing --id" do
      api_expects_no_call
      result = run_cmd(@cmd)
      assert_match("Missing arguments for '--id'.\n", result.err)
    end

    it "should return vms list" do
      params = ['--id=1']
      api_expects(:compute_resources, :available_virtual_machines) do |par|
        par['id'] == '1'
      end.returns(@available_virtual_machines)
      result = run_cmd(@cmd + params)
      assert_match(/-----|---\nNAME | ID\n-----|---\nvm1  | 1 \nvm2  | 2 \n-----|---\n/, result.out)
    end
  end

  describe "PowerCommand" do
    before do
      @cmd = ["compute-resource", "virtual-machine", "power"]
    end

    it "should print error on missing --id and --vm-id" do
      api_expects_no_call
      result = run_cmd(@cmd)
      assert_match("Could not power the virtual machine:\n  Missing arguments for '--id', '--vm-id'.\n", result.err)
    end

    it "should print error on missing --vm-id" do
      params = ['--id=1']

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_match("Could not power the virtual machine:\n  Missing arguments for '--vm-id'.\n", result.err)
    end

    it 'should power a virtual machine' do
      params = ['--id=1', '--vm-id=1']
      api_expects(:compute_resources, :power_vm) do |par|
        par['id'] == '1' && par['vm_id'] == '1'
      end.returns({})
      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Virtual machine is powering.\n"), result)
    end
  end

  describe "DeleteCommand" do
    before do
      @cmd = ["compute-resource", "virtual-machine", "delete"]
    end

    it "should print error on missing --id and --vm-id" do
      api_expects_no_call
      result = run_cmd(@cmd)
      assert_match("Could not delete the virtual machine:\n  Missing arguments for '--id', '--vm-id'.\n", result.err)
    end

    it "should print error on missing --vm-id" do
      params = ['--id=1']

      api_expects_no_call
      result = run_cmd(@cmd + params)
      assert_match("Could not delete the virtual machine:\n  Missing arguments for '--vm-id'.\n", result.err)
    end

    it 'delete virtual machine' do
      params = ['--id=1', '--vm-id=1']
      api_expects(:compute_resources, :destroy_vm) do |par|
        par['id'] == '1' && par['vm_id'] == '1'
      end.returns({})
      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Virtual machine deleted.\n"), result)
    end
  end

end
