require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')
require File.join(File.dirname(__FILE__), 'helpers/fake_searchables')

describe HammerCLIForeman do

  describe "param to resource" do

    let(:expected_resource) { HammerCLIForeman.foreman_resource!(:architectures) }

    it "finds resource for params with _id" do
      _(HammerCLIForeman.param_to_resource("architecture_id").name).must_equal expected_resource.name
    end

    it "finds resource for params without _id" do
      _(HammerCLIForeman.param_to_resource("architecture").name).must_equal expected_resource.name
    end

    it "returns nil for unknown resource" do
      assert_nil HammerCLIForeman.param_to_resource("unknown")
    end
  end

end
