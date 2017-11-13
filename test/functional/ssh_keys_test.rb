require File.join(File.dirname(__FILE__), 'test_helper')

describe 'ssh_keys' do
  let(:base_cmd) { ['user', 'ssh-keys'] }
  let(:user) do
    {
     :id => 1,
     :name => 'admin'
    }
  end
  let(:ssh_key) do
    {
      :id => 1,
      :user_id => user[:id],
      :name => 'SSH Key',
      :fingerprint => 'FINGERPRINT',
      :key => 'KEY',
      :lenght => 256
    }
  end

  describe 'list' do
    let(:cmd) { base_cmd << 'list' }

    it 'lists all ssh-keys for a given user' do
      params = ['--user-id', user[:id]]
      api_expects(:ssh_keys, :index, :user_id => user[:id])
        .returns(index_response([ssh_key]))

      expected_result = success_result(/#{ssh_key[:name]}/)

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'add' do
    let(:cmd) { base_cmd << 'add' }

    it 'adds an ssh-key to a given user' do
      params = ['--user-id', user[:id],
                '--key', ssh_key[:key],
                '--name', ssh_key[:name]]
      api_expects(:ssh_keys, :create, params)
        .returns(ssh_key)

      expected_result = success_result("SSH Key #{ssh_key[:name]} added\n")

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'adds an ssh-key to a given user with a key-file' do
      params = ['--user-id', user[:id],
                '--key-file', '~/.ssh/id_rsa.pub',
                '--name', ssh_key[:name]]
      File.stubs(:read).returns(ssh_key[:key])
      api_expects(:ssh_keys, :create, {
        :user_id => user[:id],
        :ssh_key => {
          :user_id => user[:id],
          :key => ssh_key[:key],
          :name => ssh_key[:name]
        }
      }).returns(ssh_key)

      expected_result = success_result("SSH Key #{ssh_key[:name]} added\n")

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'info' do
    let(:cmd) { base_cmd << 'info' }

    it 'shows the public key' do
      params = ['--id', ssh_key[:id],
                '--user-id', user[:id]]
      api_expects(:ssh_keys, :show, :id => ssh_key[:id])
        .returns(ssh_key)

      expected_result = success_result(/#{ssh_key[:key]}/)

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'delete' do
    let(:cmd) { base_cmd << 'delete' }

    it 'deletes an ssh-key to a given user' do
      params = ['--id', ssh_key[:id],
                '--user-id', user[:id]]
      api_expects(:ssh_keys, :destroy, :id => ssh_key[:id])
        .returns({})

      expected_result = success_result("SSH Key deleted\n")

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end
end
