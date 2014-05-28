require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')
require File.join(File.dirname(__FILE__), 'helpers/fake_searchables')

describe HammerCLIForeman::IdResolver do

  let(:api) { HammerCLIForeman.foreman_api_connection.api }
  let(:searchables) { FakeSearchables.new(['name','label']) }
  let(:resolver) { HammerCLIForeman::IdResolver.new(api, searchables) }

  describe "scoped options" do
    it "returns empty hash when there are no options" do
      resolver.scoped_options("scope", {}).must_equal({})
    end

    it "unscopes options" do
      scoped = {
        "option_id" => 1,
        "option_organization_id" => 2,
        "option_organization_name" => "ACME",
        "option_a" => :value
      }
      unscoped = {
        "option_id" => 2,
        "option_name" => "ACME",
        "option_a" => :value
      }
      resolver.scoped_options("organization", scoped).must_equal(unscoped)
    end

    it "clears old values" do
      scoped = {
        "option_id" => 1,
        "option_name" => "some name",
        "option_organization_id" => 2,
        "option_a" => :value
      }
      unscoped = {
        "option_id" => 2,
        "option_a" => :value
      }
      resolver.scoped_options("organization", scoped).must_equal(unscoped)
    end

    it "does not change the original options" do
      scoped = {
        "option_id" => 1,
        "option_organization_id" => 2,
        "option_organization_name" => "ACME",
        "option_a" => :value
      }
      scoped_original = scoped.dup
      resolver.scoped_options("organization", scoped)
      scoped.must_equal(scoped_original)
    end

  end


  describe "id params" do
      let(:required_params) {[
        stub(:name => "architecture_id", :required? => true),
        stub(:name => "organization_id", :required? => true)
      ]}
      let(:id_params) {[
        stub(:name => "domain_id", :required? => false)
      ]}
      let(:other_params) {[
        stub(:name => "location", :required? => true),
        stub(:name => "param", :required? => false)
      ]}
      let(:action) {
        stub(:params => (required_params+id_params+other_params))
      }

    it "returns only required params ending with _id" do
      resolver.id_params(action, :required => true).must_equal required_params
    end

    it "returns only ending with _id when :required is set to false" do
      resolver.id_params(action, :required => false).must_equal (required_params+id_params)
    end

    it "returns required params by default" do
      resolver.id_params(action).must_equal required_params
    end
  end

  describe "param to resource" do

    let(:expected_resource) { HammerCLIForeman.foreman_resource(:architectures) }

    it "finds resource for params with _id" do
      resolver.param_to_resource("architecture_id").name.must_equal expected_resource.name
    end

    it "finds resource for params without _id" do
      resolver.param_to_resource("architecture").name.must_equal expected_resource.name
    end

    it "returns nil for unknown resource" do
      resolver.param_to_resource("unknown").must_equal nil
    end

  end

  describe "depedent resources" do

    it "returns empty array for an independent resource" do
      resource = HammerCLIForeman.foreman_resource(:architectures)
      resolver.dependent_resources(resource).must_equal []
    end

    it "returns list of dependent resources" do
      resource = HammerCLIForeman.foreman_resource(:images)
      resolver.dependent_resources(resource).map(&:name).must_equal [:compute_resources]
    end

  end

  describe "resolving ids" do

    it "must define methods for all resources" do
      expected_method_names = api.resources.map(&:singular_name).collect{|r| "#{r}_id"}
      missing_methods = expected_method_names - resolver.methods.map(&:to_s)
      missing_methods.must_equal []
    end

    describe "when no search options are found" do
      let(:resolver_run) { proc { resolver.architecture_id({"option_unknown" => "value"}) } }

      it "raises exception" do
        err = resolver_run.must_raise HammerCLIForeman::MissingSeachOptions
      end

      it "builds correct error message" do
        err = resolver_run.must_raise HammerCLIForeman::MissingSeachOptions
        err.message.must_equal "Missing options to search architecture"
      end
    end

    describe "searching independent resource" do
      let(:resolver_run) { proc { resolver.architecture_id({"option_name" => "arch"}) } }

      it "raises exception when no resource is found" do
        ResourceMocks.mock_action_call(:architectures, :index, [])

        err = resolver_run.must_raise HammerCLIForeman::ResolverError
        err.message.must_equal "architecture not found"
      end

      it "raises exception when multiple resources are found" do
        ResourceMocks.mock_action_call(:architectures, :index, [
          {"id" => 11, "name" => "arch1"},
          {"id" => 22, "name" => "arch2"}
        ])

        err = resolver_run.must_raise HammerCLIForeman::ResolverError
        err.message.must_equal "architecture found more than once"
      end

      it "calls index action with appropriate search params" do
        ApipieBindings::API.any_instance.expects(:call).with() do |resource, action, params, headers, opts|
          ( resource == :architectures &&
            action == :index &&
            params[:search] == "name = \"arch\"")
        end.returns({"id" => 11, "name" => "arch1"})

        resolver_run.call
      end

      it "uses option id when it's available" do
        ResourceMocks.mock_action_call(:architectures, :index, [])

        resolver.architecture_id({"option_id" => 83, "option_name" => "arch"}).must_equal 83
      end

      it "returns id of the resource" do
        ResourceMocks.mock_action_call(:architectures, :index, [
          {"id" => 11, "name" => "arch1"}
        ])

        resolver_run.call.must_equal 11
      end

    end

    describe "searching dependent resource" do
      let(:resolver_run) { proc { resolver.image_id({"option_name" => "img", "option_compute_resource_name" => "cr"}) } }

      it "raises exception when no resource is found" do
        ResourceMocks.mock_action_call(:images, :index, [])
        ResourceMocks.mock_action_call(:compute_resources, :index, [])

        err = resolver_run.must_raise HammerCLIForeman::ResolverError
        err.message.must_equal "compute_resource not found"
      end

      it "raises exception when multiple resources are found" do
        ResourceMocks.mock_action_call(:images, :index, [])
        ResourceMocks.mock_action_call(:compute_resources, :index, [
          {"id" => 11, "name" => "cr1"},
          {"id" => 22, "name" => "cr2"}
        ])

        err = resolver_run.must_raise HammerCLIForeman::ResolverError
        err.message.must_equal "compute_resource found more than once"
      end

      it "calls index action with appropriate search params" do
        ApipieBindings::API.any_instance.expects(:call).with() do |resource, action, params, headers, opts|
          ( resource == :compute_resources &&
            action == :index &&
            params[:search] == "name = \"cr\"")
        end.returns({"id" => 11, "name" => "cr"})

        ApipieBindings::API.any_instance.expects(:call).with() do |resource, action, params, headers, opts|
          ( resource == :images &&
            action == :index &&
            params[:search] == "name = \"img\"")
        end.returns({"id" => 11, "name" => "img"})

        resolver_run.call
      end

      it "returns id of the resource" do
        ResourceMocks.mock_action_call(:images, :index, [
          {"id" => 11, "name" => "img1"}
        ])
        ResourceMocks.mock_action_call(:compute_resources, :index, [
          {"id" => 22, "name" => "cr2"}
        ])

        resolver_run.call.must_equal 11
      end
    end

  end
end
