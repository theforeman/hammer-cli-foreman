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
      cmd.stubs(:get_resource_ids).returns([1])
      option_data = { 'option_location_ids' => [3], 'option_location_names' => 'test' }
      params = ids_params_source.get_options([], option_data)
      params.must_equal option_data
    end

    it "resolves param when unset" do
      cmd.stubs(:get_resource_ids).returns([1])
      option_data = { 'option_location_id' => nil, 'option_location_names' => 'test' }
      params = ids_params_source.get_options([], option_data)
      params['option_location_ids'].must_equal [1]
    end
  end
end
