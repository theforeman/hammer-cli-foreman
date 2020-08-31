require File.join(File.dirname(__FILE__), 'test_helper')

describe 'audit' do
  before do
    @audit_changed = {
      'id' => 83,
      'created_at' => "2017-10-31 11:25:44 UTC",
      'remote_address' => '::1',
      'user_name' => "foreman_api_admin",
      'user_id' => 11,
      'action' => "update",
      'auditable_type' => "ProvisioningTemplate",
      'auditable_name' => "default_location_subscribed_hosts",
      'auditable_id' => 32,
      'audited_changes' => {
        'value' => [
          nil,
          "--- false\n..."
        ]
      }
    }
  end
  describe 'audit-info' do
    let (:cmd) { ['audit', 'info'] }
    let(:params) { ['--id=83'] }
    let(:audit_new) do
      {
        "user_id" => 1,
        "user_type" => nil,
        "user_name" => "foreman_admin",
        "version" => 1,
        "comment" => nil,
        "associated_id" => nil,
        "associated_type" => nil,
        "remote_address" => "::1",
        "associated_name" => nil,
        "created_at" => "2017-10-09 23:42:44 -1100",
        "id" => 63,
        "auditable_id" => 5,
        "auditable_name" => "John Doe",
        "auditable_type" => "User",
        "action" => "create",
        "audited_changes" => {
          "login" => "john",
          "firstname" => "John",
          "lastname" => "Doe",
          "mail" => "john@ipa.test",
          "admin" => false,
          "auth_source_id" => 3,
          "locale" => nil,
          "avatar_hash" => nil,
          "default_organization_id" => nil,
          "default_location_id" => nil,
          "lower_login" => "john",
          "mail_enabled" => true,
          "timezone" => nil,
          "description" => nil
        }
      }
    end

    it 'shows audit information for changed records' do
      api_expects(:audits, :show, 'info')
        .with_params('id' => '83')
        .returns(@audit_changed)

      output = OutputMatcher.new(
        [
          'Id:              83',
          'At:              2017/10/31 11:25:44',
          'IP:              ::1',
          'User:            foreman_api_admin',
          'Action:          update',
          'Audit type:      ProvisioningTemplate',
          'Audit record:    default_location_subscribed_hosts',
          'Audited changes:',
          ' 1) Attribute: value',
          '    Old:',
          '',
          '    New:',
          '      --- false',
          '      ...',
        ]
      )
      expected_result = success_result(output)

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'shows audit information for new records' do
      api_expects(:audits, :show, 'info')
        .with_params('id' => '83')
        .returns(audit_new)

      output = OutputMatcher.new(
        [
          'Id:              63',
          'At:              2017/10/09 23:42:44',
          'IP:              ::1',
          'User:            foreman_admin',
          'Action:          create',
          'Audit type:      User',
          'Audit record:    John Doe',
          'Audited changes:',
          ' 1) Attribute: login',
          '    Value:     john',
          ' 2) Attribute: firstname',
          '    Value:     John',
          ' 3) Attribute: lastname',
          '    Value:     Doe',
          ' 4) Attribute: mail',
          '    Value:     john@ipa.test',
          ' 5) Attribute: admin',
          '    Value:     false',
          ' 6) Attribute: auth_source_id',
          '    Value:     3',
          ' 7) Attribute: lower_login',
          '    Value:     john',
          ' 8) Attribute: mail_enabled',
          '    Value:     true',
        ]
      )
      expected_result = success_result(output)

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'audit-list' do
    let(:cmd) { ['audit', 'list'] }
    let(:audits) do
      [@audit_changed]
    end

    it "should show index list" do
      api_expects(:audits, :index).returns(audits)

      output = IndexMatcher.new([
                                  ['ID', 'AT', 'IP', 'USER', 'ACTION', 'AUDIT TYPE', 'AUDIT RECORD'],
                                  ['83', '2017/10/31 11:25:44', '::1', 'foreman_api_admin', 'update', 'ProvisioningTemplate', 'default_location_subscribed_hosts']
                                ])

      result = run_cmd(cmd)
      assert_cmd(success_result(output), result)
    end
  end
end
