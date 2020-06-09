require File.join(File.dirname(__FILE__), 'test_helper')

describe 'trend' do
  describe 'list' do
    before do
      @cmd = %w[trend list]
      @trends =
        [{
           id: 1,
           label: "Operatingsystem",
           trendable_type: "Operatingsystem",
           name: "os_trend" }]
    end

    it 'should return a list of trends' do
      api_expects(:trends, :index, 'List trends').returns(@trends)

      result = run_cmd(@cmd)
      result.exit_code.must_equal HammerCLI::EX_OK
    end
  end

  describe 'info' do
    before do
      @cmd = %w[trend info]
      @trend = {
        id: 1,
        label: "Operatingsystem",
        trendable_type: "Operatingsystem",
        name: "os_trend"
      }
    end

    it 'should return a trend' do
      params = ['--id=1']
      api_expects(:trends, :show, 'Show trend').returns(@trend)

      result = run_cmd(@cmd + params)
      result.exit_code.must_equal HammerCLI::EX_OK
    end
  end

  describe 'create' do
    before do
      @cmd = %w[trend create]
    end

    it 'should print error on missing --trendable-type' do
      expected_result = "Could not create the trend:\n  Missing arguments for '--trendable-type'.\n"

      api_expects_no_call
      result = run_cmd(@cmd)
      assert_match(expected_result, result.err)
    end

    it 'should create a trend' do
      params = ['--trendable-type=ComputeResource']

      api_expects(:trends, :create, 'Create a trend') do |params|
        (params['trendable_type'] == 'ComputeResource')
      end

      result = run_cmd(@cmd + params)

      assert_cmd(success_result("Trend for %<trendable_type>s created.\n"), result)
    end
  end

  describe 'delete' do
    before do
      @cmd = %w[trend delete]
    end

    it 'should delete a trend' do
      params = ['--id=1']

      api_expects(:trends, :destroy, 'Delete trend').with_params(:id => '1')

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Trend for %<trendable_type>s deleted.\n"), result)
    end
  end
end
