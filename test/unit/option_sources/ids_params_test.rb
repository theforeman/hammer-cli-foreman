require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLIForeman::OptionSources::IdsParams do
  describe "get_options" do
    class IdsParamsTestCommand < HammerCLIForeman::CreateCommand
      resource :users
      build_options
    end

    let(:cmd) { IdsParamsTestCommand.new("", { :adapter => :csv, :interactive => false }) }
    let(:ids_params_source) { HammerCLIForeman::OptionSources::IdsParams.new(cmd) }

    it "skips param when set" do
      cmd.stubs(:get_resource_ids).returns(nil)
      cmd.expects(:get_resource_ids).with { |res| res.name == :locations }.never
      option_data = { 'option_location_ids' => [3], 'option_location_names' => 'test' }
      params = ids_params_source.get_options([], option_data)
      _(params).must_equal option_data
    end

    it "resolves param when unset" do
      cmd.stubs(:get_resource_ids).returns(nil)
      cmd.expects(:get_resource_ids).with { |res| res.name == :locations }.returns([1])
      option_data = { 'option_location_ids' => nil, 'option_location_names' => 'test' }
      expected_data = { 'option_location_ids' => [1], 'option_location_names' => 'test' }
      params = ids_params_source.get_options([], option_data)
      _(params).must_equal expected_data
    end
  end
end
