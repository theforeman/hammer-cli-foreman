require File.join(File.dirname(__FILE__), 'test_helper')

describe HammerCLIForeman::Defaults do
  let(:user) {
    {"default_organization" => {"id" => 2}, "default_location" => {"id" => 1}}
  }
  let(:empty_user) {
    {"default_organization" => nil, "default_location" => nil}
  }

  before do
    connection = api_connection
    @api = APIExpectationsDecorator.new(connection.api)
    @defaults_provider = HammerCLIForeman::Defaults.new(connection)
  end

  it "returns defaults organization when exisits " do
    @api.expects_search(:users, 'login=admin').returns(index_response([user]))
    assert_equal 2, @defaults_provider.get_defaults(:organization_id)
  end

  it "returns nil when defaults organization doesn't exisits " do
    @api.expects_search(:users, 'login=admin').returns(index_response([empty_user]))
    assert_nil @defaults_provider.get_defaults(:organization_id)
  end

  it "returns defaults location when exisits " do
    @api.expects_search(:users, 'login=admin').returns(index_response([user]))
    assert_equal 1, @defaults_provider.get_defaults(:location_id)
  end

  it "returns nil when defaults location doesn't exisits " do
    @api.expects_search(:users, 'login=admin').returns(index_response([empty_user]))
    assert_nil @defaults_provider.get_defaults(:location_id)
  end
end
