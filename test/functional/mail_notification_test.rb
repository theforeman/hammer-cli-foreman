require File.join(File.dirname(__FILE__), 'test_helper')

describe 'mail_notification' do
  describe 'list' do
    before do
      @cmd = %w[mail-notification list]
      @mail_notifications = [{
        id: 1,
        name: 'config_summary',
        description: 'A summary of eventful configuration management reports',
        subscription_type: 'report'
      }]
    end

    it 'should return a list of mail notifications' do
      api_expects(:mail_notifications, :index, 'List mail notifications').returns(@mail_notifications)

      output = IndexMatcher.new([
                                  %w[ID NAME],
                                  %w[1 config_summary]
                                ])
      expected_result = success_result(output)

      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end

    it 'should run list command with defaults' do
      providers = { 'foreman' => HammerCLIForeman::Defaults.new(api_connection({}, FOREMAN_VERSION)) }
      defaults = HammerCLI::Defaults.new(
        {
          organization_id: {
            provider: 'foreman'
          },
          location_id: {
            provider: 'foreman'
          }
        }
      )
      defaults.stubs(:write_to_file).returns(true)
      defaults.stubs(:providers).returns(providers)
      api_expects(:users, :index, 'Find user').with_params(search: 'login=admin').returns(index_response([{ 'default_organization' => { 'id' => 2 } }]))
      api_expects(:users, :index, 'Find user').with_params(search: 'login=admin').returns(index_response([{ 'default_location' => { 'id' => 1 } }]))
      api_expects(:mail_notifications, :index, 'List mail notifications').returns(@mail_notifications)

      result = run_cmd(@cmd, { use_defaults: true, defaults: defaults })
      _(result.exit_code).must_equal HammerCLI::EX_OK
    end
  end

  describe 'info' do
    before do
      @cmd = %w[mail-notification info]
      @mail_notification = {
        id: 1,
        name: 'config_summary',
        description: 'A summary of eventful configuration management reports',
        subscription_type: 'report'
      }
    end

    it 'should return the info of a mail notification' do
      params = ['--id=1']
      api_expects(:mail_notifications, :show, 'Info mail notification').returns(@mail_notification)

      output = OutputMatcher.new([
                                   'Id:                1',
                                   'Name:              config_summary',
                                   'Description:       A summary of eventful configuration management reports',
                                   'Subscription type: report'
                                 ])

      expected_result = success_result(output)

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end
  end
end
