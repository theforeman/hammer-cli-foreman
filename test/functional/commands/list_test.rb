require File.join(File.dirname(__FILE__), '..', 'test_helper')

describe HammerCLIForeman::ListCommand do
  class TestList < HammerCLIForeman::ListCommand
    resource :domains

    option '--page', 'PAGE', ''
    option '--per-page', 'PER_PAGE', ''
  end

  class TestListWithOutput < TestList
    output do
      field :id, "Id"
      field :name, "Name"
    end
  end

  def build_items(cnt)
    (1..cnt).map do |i|
      {:id => i, :name => "Item #{i}"}
    end
  end

  def expect_paged_call(page, per_page, item_cnt, response_metadata={})
    api_expects(:domains, :index, "List records page #{page}") do |par|
      par["page"].to_i == page && par["per_page"].to_i == per_page
    end.returns(index_response(build_items(item_cnt), response_metadata))
  end

  let(:per_page_all) { HammerCLIForeman::ListCommand::RETRIEVE_ALL_PER_PAGE }

  after do
    HammerCLI::Settings.clear
  end

  describe "api interaction" do
    context "without per_page in settings" do
      it "fetches only first page when there's not enough records" do
        expect_paged_call(1, 1000, 10)
        result = run_cmd([], {}, TestList)
        result.exit_code.must_equal HammerCLI::EX_OK
      end

      it "fetches all records" do
        expect_paged_call(1, per_page_all, 1000)
        expect_paged_call(2, per_page_all, 1000)
        expect_paged_call(3, per_page_all, 10)

        result = run_cmd([], {}, TestList)
        result.exit_code.must_equal HammerCLI::EX_OK
      end

      it "uses --per-page value" do
        per_page = 10
        expect_paged_call(1, per_page, 10)
        result = run_cmd(["--per-page=#{per_page}"], {}, TestList)
        result.exit_code.must_equal HammerCLI::EX_OK
      end

      it "uses both --per-page and --page value" do
        per_page = 10
        expect_paged_call(2, per_page, 10)
        result = run_cmd(["--per-page=#{per_page}", '--page=2'], {}, TestList)
        result.exit_code.must_equal HammerCLI::EX_OK
      end

      it "sets per_page to 20 when only --page is used" do
        expect_paged_call(2, 20, 10)
        result = run_cmd(['--page=2'], {}, TestList)
        result.exit_code.must_equal HammerCLI::EX_OK
      end
    end

    context "with per_page in settings" do
      let(:per_page_in_settings) { 30 }
      before do
        HammerCLI::Settings.load({ :ui => { :per_page => per_page_in_settings } })
      end

      it "gives preference to --per-page option over per_page setting" do
        per_page = 10
        expect_paged_call(1, per_page, 10)
        result = run_cmd(["--per-page=#{per_page}"], {}, TestList)
        result.exit_code.must_equal HammerCLI::EX_OK
      end

      it "respects per_page setting when the adapter allows pagination by default" do
        expect_paged_call(1, per_page_in_settings, 30)
        result = run_cmd([], { :adapter => :base, :interactive => false }, TestList)
        result.exit_code.must_equal HammerCLI::EX_OK
      end

      it "fetches all records when the adapter doesn't allow pagination by default" do
        expect_paged_call(1, per_page_all, 1000)
        expect_paged_call(2, per_page_all, 10)
        result = run_cmd([], { :adapter => :csv, :interactive => false }, TestList)
        result.exit_code.must_equal HammerCLI::EX_OK
      end
    end
  end

  describe "pagination output" do
    let(:row_data) { ['1', 'Item 1'] }
    let(:header) { ['ID', 'NAME'] }
    let(:pagination) { ['Page 1 of 2 (use --page and --per-page for navigation)'] }
    let(:output_without_pagination) { IndexMatcher.new([header, row_data]) }
    let(:output_with_pagination) { IndexMatcher.new([header, row_data, pagination]) }
    let(:pagination_line_re) { /Page [1-9] of [0-9]/ }

    it 'prints all rows by default' do
      expected_result = success_result(output_without_pagination)
      expect_paged_call(1, per_page_all, 1)

      result = run_cmd([], {}, TestListWithOutput)
      assert_cmd(expected_result, result)
      result.out.wont_match pagination_line_re
    end

    it 'prints one page when --per-page is used' do
      expected_result = success_result(output_with_pagination)
      expect_paged_call(1, 1, 1, :total => 2, :subtotal => 2, :per_page => 1, :page => 1)

      result = run_cmd(['--per-page=1'], {}, TestListWithOutput)
      assert_cmd(expected_result, result)
    end

    context 'with per_page in settings' do
      before do
        HammerCLI::Settings.load({ :ui => { :per_page => '1' } })
      end

      it 'prints one page when per_page is set in the config' do
        expected_result = success_result(output_with_pagination)
        expect_paged_call(1, 1, 1, :total => 2, :subtotal => 2, :per_page => 1, :page => 1)

        result = run_cmd([], {}, TestListWithOutput)
        assert_cmd(expected_result, result)
      end
    end
  end
end
