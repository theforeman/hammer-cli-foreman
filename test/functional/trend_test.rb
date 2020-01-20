require File.join(File.dirname(__FILE__), 'test_helper')

describe 'trend' do
  describe 'list' do
    before do
      @cmd = %w(trend list)
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
end
