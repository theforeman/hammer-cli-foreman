require File.join(File.dirname(__FILE__), 'test_helper')

describe 'user_mail_notification' do
  before do
    @user_mail_notifications = [{
                                  id: 1,
                                  user_id: 2,
                                  mail_notification_id: 3,
                                  interval: "Daily",
                                  mail_query: "",
                                  name: 'config_summary',
                                  description: 'A summary of eventful configuration management reports'
                                }]
  end
  describe 'list' do
    before do
      @cmd = %w[user mail-notification list]
    end

    it 'should return a list of the user mail notifications' do
      params = ['--user-id=2']
      api_expects(:mail_notifications, :user_mail_notifications, 'List user mail notifications').returns(@user_mail_notifications)

      output = IndexMatcher.new([
                                    ['ID', 'NAME', 'DESCRIPTION', 'INTERVAL', 'MAIL QUERY'],
                                    ['3', 'config_summary', 'A summary of eventful configuration management reports', 'Daily', '']
                                ])
      expected_result = success_result(output)

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'update' do
    before do
      @cmd = %w[user mail-notification update]
    end

    it 'should update a user mail notification' do
      params = ['--user-id=2', '--mail-notification-id=3', '--interval=weekly']
      api_expects(:mail_notifications, :update, 'Update user mail notification')

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("User mail notifications was updated.\n"), result)
    end
  end

  describe 'create' do
    before do
      @cmd = %w[user mail-notification add]
    end

    it 'should return an error that there is no mail-notification' do
      params = ['--user-id=2']

      expected_result = common_error_result(
          @cmd,
          "Could not find mail_notification, please set one of options --mail-notification, --mail-notification-id.",
          "Could not add user mail notification"
      )

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'should add a user mail notification' do
      params = ['--user-id=2', '--mail-notification-id=3', '--interval=daily']
      api_expects(:mail_notifications, :create, 'Create user mail notification')

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("User mail notifications was added.\n"), result)
    end
  end

  describe 'remove' do
    before do
      @cmd = %w[user mail-notification remove]
    end

    it 'should remove a user mail notification' do
      params = ['--user-id=2', '--mail-notification-id=3']
      api_expects(:mail_notifications, :destroy, 'Remove user mail notification')

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("User mail notification was removed.\n"), result)
    end
  end
end
