require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')
require File.join(File.dirname(__FILE__), 'helpers/fake_searchables')

describe HammerCLIForeman::DependencyResolver do

  let(:resolver) { HammerCLIForeman::DependencyResolver.new }

  describe "for resource" do

    it "returns empty array for an independent resource" do
      resource = HammerCLIForeman.foreman_resource!(:architectures)
      resolver.resource_dependencies(resource).must_equal []
    end

    it "returns list of dependent resources" do
      resource = HammerCLIForeman.foreman_resource!(:images)
      resolver.resource_dependencies(resource).map(&:name).must_equal [:compute_resources]
    end

  end

  describe "for action" do

    it "returns empty array for an independent action" do
      action = HammerCLIForeman.foreman_resource!(:organizations).action(:index)
      resolver.action_dependencies(action).must_equal []
    end

    it "returns list of dependent resources" do
      action = HammerCLIForeman.foreman_resource!(:hostgroups).action(:create)
      resolver.action_dependencies(action).map(&:name).sort_by{|sym| sym.to_s}.must_equal [
        :environments, :operatingsystems, :architectures, :media,
        :ptables, :subnets, :domains, :realms
      ].sort_by{|sym| sym.to_s}
    end

  end

end


