require File.join(File.dirname(__FILE__), 'test_helper')

describe 'proxy' do
  describe 'import-classes' do
    let(:cmd) { ['proxy', 'import-classes'] }
    let(:params) { ['--id=83'] }
    let(:report) do
      {
        'message' => 'Successfully updated environment and puppetclasses from the on-disk puppet installation',
        'environments_with_new_puppetclasses' => 2,
        'environments_updated_puppetclasses' => 0,
        'environments_obsolete' => 0,
        'environments_ignored' => 0,
        'results' => [{
          'name' => 'development',
          'actions' => [ 'new', 'update' ],
          'new_puppetclasses' => [
            'motd',
            'hammer'
          ],
          'updated_puppetclasses' => [
            'stdlib',
            'vim'
          ]
        },{
          'name' => 'production',
          'actions' => [ 'obsolete', 'ignore' ],
          'obsolete_puppetclasses' => [
            'apache'
          ],
          'ignored_puppetclasses' => [
            'hammer'
          ]
        }]
      }
    end
    let(:no_change_report) do
      {
        'message' => 'No changes to your environments detected'
      }
    end

    it 'prints detailed report' do
      api_expects(:smart_proxies, :import_puppetclasses, 'Import classes')
        .with_params('id' => '83')
        .returns(report)

      output = OutputMatcher.new([
        'Result:',
        '  Successfully updated environment and puppetclasses from the on-disk puppet installation',
        'Changed environments:',
        ' 1) development',
        '    New classes:',
        '        motd',
        '        hammer',
        '    Updated classes:',
        '        stdlib',
        '        vim',
        ' 2) production',
        '    Removed classes:',
        '        apache',
        '    Ignored classes:',
        '        hammer'
      ])
      expected_result = success_result(output)

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'prints a message when nothig has changed' do
      api_expects(:smart_proxies, :import_puppetclasses, 'Import classes')
        .with_params('id' => '83')
        .returns(no_change_report)

      output = OutputMatcher.new([
        'Result:',
        '  No changes to your environments detected'
      ])
      expected_result = success_result(output)

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end
end
