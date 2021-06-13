require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLIForeman::OptionSources::IdParams do
  describe "get_options" do
    class IdParamsTestCommand < HammerCLIForeman::CreateCommand
      resource :hostgroups
      build_options
    end

    let(:hg_cmd) { IdParamsTestCommand.new("", { :adapter => :csv, :interactive => false }) }
    let(:id_params_source) { HammerCLIForeman::OptionSources::IdParams.new(hg_cmd) }

    it "skips param when set" do
      hg_cmd.stubs(:get_resource_id).returns(nil)
      hg_cmd.expects(:get_resource_id).with { |res| res.name == :domains }.never
      option_data = { 'option_domain_id' => 3, 'option_domain_name' => 'test' }
      params = id_params_source.get_options([], option_data)
      _(params).must_equal option_data
    end

    it "resolves param when unset" do
      hg_cmd.stubs(:get_resource_id).returns(nil)
      hg_cmd.expects(:get_resource_id).with { |res| res.name == :domains }.returns(1)
      option_data = { 'option_domain_id' => nil, 'option_domain_name' => 'test' }
      expected_data = { 'option_domain_id' => 1, 'option_domain_name' => 'test' }
      params = id_params_source.get_options([], option_data)
      _(params).must_equal expected_data
    end

    it 'resolves param when set but different name' do
      hg_cmd.stubs(:get_resource_id).returns(nil)
      hg_cmd.expects(:get_resource_id).with { |res| res.name == :domains }.returns(3)
      option_data = { 'option_domain_id' => 1, 'option_domain_name' => 'test3' }
      expected_data = { 'option_domain_id' => 3, 'option_domain_name' => 'test3' }
      params = id_params_source.get_options([], option_data)
      _(params).must_equal expected_data
    end
  end
end
