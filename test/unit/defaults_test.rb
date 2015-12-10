require File.join(File.dirname(__FILE__), 'test_helper')
describe HammerCLIForeman::Defaults do

  context "Defaults" do

    defaults_provider = HammerCLIForeman::Defaults.new
    user = {"results" => ["default_organization" => {"id" => 2}, "default_location" => {"id" => 1}]}
    empty_user = {"results" => ["default_organization" => nil, "default_location" => nil]}

    it "returns defaults organization when exisits " do
      defaults_provider.stubs(:get_user).returns user
      assert_equal 2, defaults_provider.get_defaults(:organization_id)
    end

    it "returns nil when defaults organization doesn't exisits " do
      defaults_provider.stubs(:get_user).returns empty_user
      assert_nil defaults_provider.get_defaults(:organization_id)
    end

    it "returns defaults location when exisits " do
      defaults_provider.stubs(:get_user).returns user
      assert_equal 1, defaults_provider.get_defaults(:location_id)
    end

    it "returns nil when defaults location doesn't exisits " do
      defaults_provider.stubs(:get_user).returns empty_user
      assert_nil defaults_provider.get_defaults(:location_id)
    end

  end

end
