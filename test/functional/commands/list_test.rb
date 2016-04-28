require File.join(File.dirname(__FILE__), '..', 'test_helper')

describe "ListCommand" do
  describe "pagination" do
    let(:row1) { { :id => '1', :name => 'Name', :type => 'Type' } }
    let(:row2) { { :id => '2', :name => 'Name', :type => 'Type' } }
    let(:header) { ['ID', 'NAME', 'TYPE'] }
    let(:pagination) { ['Page 1 of 2 (use --page and --per-page for navigation)'] }
    let(:output_without_pagination) { IndexMatcher.new([header, row1.values]) }
    let(:output_with_pagination) { IndexMatcher.new([header, row1.values, pagination]) }

    it 'prints all rows by default' do
      expected_result = success_result(output_without_pagination)
      api_expects(:config_templates, :index, "List all parameters") do |par|
        par["page"] == 1 && par["per_page"] == 1000
      end.returns(index_response([row1]))

      result = run_cmd(['template', 'list'], {})
      assert_cmd(expected_result, result)
      result.out.wont_match /Page [1-9] of [0-9]/
    end

    it 'prints one page when --per-page is used' do
      expected_result = success_result(output_with_pagination)
      api_expects(:config_templates, :index, "List 1st page") do |par|
        par["page"].to_i == 1 && par["per_page"].to_i == 1
      end.returns(index_response([row1], :total => 2, :subtotal => 2, :per_page => 1, :page => 1))

      result = run_cmd(['template', 'list', '--per-page=1'], {})
      assert_cmd(expected_result, result)
    end

    context 'in settings' do
      before :all do
        HammerCLI::Settings.load({ :ui => { :per_page => '1' } })
      end
      after :all do
        HammerCLI::Settings.load({ :ui => { :per_page => nil } })
      end

      it 'prints one page when per_page is set in the config' do
        expected_result = success_result(output_with_pagination)
        api_expects(:config_templates, :index, "List 1st page") do |par|
          par["page"].to_i == 1 && par["per_page"].to_i == 1
        end.returns(index_response([row1], :total => 2, :subtotal => 2, :per_page => 1, :page => 1))

        result = run_cmd(['template', 'list'], {})
        assert_cmd(expected_result, result)
      end
    end
  end
end
