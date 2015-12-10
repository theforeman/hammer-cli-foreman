require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')
require File.join(File.dirname(__FILE__), 'helpers/fake_searchables')

describe HammerCLIForeman::DependencyResolver do

  let(:api) do ApipieBindings::API.new({
    :apidoc_cache_dir => 'test/unit/data',
    :apidoc_cache_name => 'test_api',
    :dry_run => true})
  end

  before :each do
    HammerCLIForeman.stubs(:foreman_api).returns(api)
  end

  let(:resolver) { HammerCLIForeman::DependencyResolver.new }

  describe "for resource" do

    it "returns empty array for an independent resource" do
      resource = api.resource(:users)
      resolver.resource_dependencies(resource).must_equal []
    end

    it "returns list of dependent resources" do
      resource = api.resource(:comments)

      resources = resolver.resource_dependencies(resource).map(&:name).sort_by{ |sym| sym.to_s }
      expected = [:posts, :users]
      resources.must_equal expected.sort_by{ |sym| sym.to_s }
    end
  end

  describe "for action" do

    it "returns empty array for an independent action" do
      action = HammerCLIForeman.foreman_resource!(:users).action(:index)
      resolver.action_dependencies(action).must_equal []
    end

    it "returns list of dependent resources" do
      action = HammerCLIForeman.foreman_resource!(:comments).action(:create)
      resources = resolver.action_dependencies(action).map(&:name).sort_by{ |sym| sym.to_s }
      expected = [:posts, :users]
      resources.must_equal expected.sort_by{|sym| sym.to_s}
    end
  end
end
