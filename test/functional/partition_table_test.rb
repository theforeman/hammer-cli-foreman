require File.join(File.dirname(__FILE__), 'test_helper')

describe 'partition-table' do
  describe 'import' do
    let(:template) do
      {
        'id' => 1,
        'template' => 'Template content'
      }
    end
    let(:cmd) { %w(partition-table import) }
    let(:tempfile) { Tempfile.new('template') }

    it 'requires --name and --file' do
      params = ['--name=test']
      api_expects_no_call
      expected_result = usage_error_result(
        cmd,
        'Options --name, --file are required.',
        'Could not import partition table template')
      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'import template' do
      params = ['--name=test', "--file=#{tempfile.path}"]
      tempfile.write('Template content')
      tempfile.rewind
      api_expects(:ptables, :import, 'Import partition table template').with_params(
        'ptable' => {
          'name' => 'test',
          'template' => 'Template content'
        }).returns(template)

      result = run_cmd(cmd + params)
      assert_cmd(success_result("Import partition table template succeeded.\n"), result)
    end
  end
end
