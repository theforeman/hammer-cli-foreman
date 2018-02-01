require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')
require File.join(File.dirname(__FILE__), 'helpers/fake_searchables')

describe HammerCLIForeman::IdResolver do

  let(:api) do ApipieBindings::API.new({
    :apidoc_cache_dir => 'test/unit/data',
    :apidoc_cache_name => 'test_api',
    :dry_run => true})
  end
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

    let(:scoped_multi) {{
      "option_id" => 1,
      "option_organization_id" => 2,
      "option_organization_ids" => 3,
      "option_organization_name" => "ACME",
      "option_organization_names" => "Corp",
      "option_a" => :value
    }}

    it "unscopes the right options in single mode" do
      unscoped = {
        "option_id" => 2,
        "option_organization_ids" => 3,
        "option_organization_names" => "Corp",
        "option_name" => "ACME",
        "option_a" => :value
      }
      resolver.scoped_options("organization", scoped_multi, :single).must_equal(unscoped)
    end

    it "unscopes the right options in multi mode" do
      unscoped = {
        "option_id" => 1,
        "option_organization_id" => 2,
        "option_ids" => 3,
        "option_organization_name" => "ACME",
        "option_names" => "Corp",
        "option_a" => :value
      }
      resolver.scoped_options("organization", scoped_multi, :multi).must_equal(unscoped)
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


  describe "resolving ids" do
    let(:john_id) { 11 }
    let(:john) { {"id" => john_id, "name" => "John Doe"} }
    let(:jane_id) { 22 }
    let(:jane) { {"id" => jane_id, "name" => "Jane Doe"} }

    it "must define methods for all resources" do
      expected_method_names = api.resources.map(&:singular_name).collect{|r| "#{r}_id"}
      missing_methods = expected_method_names - resolver.methods.map(&:to_s)
      missing_methods.must_equal []
    end

    describe "when no search options are found" do
      let(:resolver_run) { proc { resolver.comment_id({"option_unknown" => "value"}) } }

      it "raises exception" do
        err = resolver_run.must_raise HammerCLIForeman::MissingSearchOptions
      end

      it "builds correct error message" do
        err = resolver_run.must_raise HammerCLIForeman::MissingSearchOptions
        err.message.must_equal "Missing options to search comment."
      end
    end

    describe "searching independent resource" do
      let(:resolver_run) { proc { resolver.user_id({"option_name" => "John Doe"}) } }

      it "raises exception when no resource is found" do
        ResourceMocks.mock_action_call(:users, :index, [])

        err = resolver_run.must_raise HammerCLIForeman::ResolverError
        err.message.must_equal "user not found."
      end

      it "raises exception when multiple resources are found" do
        ResourceMocks.mock_action_call(:users, :index, [john, jane])

        err = resolver_run.must_raise HammerCLIForeman::ResolverError
        err.message.must_equal "Found more than one user."
      end

      it "calls index action with appropriate search params" do
        ApipieBindings::API.any_instance.expects(:call).with() do |resource, action, params, headers, opts|
          ( resource == :users &&
            action == :index &&
            params[:search] == "name = \"John Doe\"")
        end.returns(john)

        resolver_run.call
      end

      it "uses option id when it's available" do
        ResourceMocks.mock_action_call(:users, :index, [])

        resolver.user_id({"option_id" => 83, "option_name" => "John Doe"}).must_equal 83
      end

      it "returns NIL when the search name is NIL" do
        resolver.user_id({"option_name" => HammerCLI::NilValue}).must_equal HammerCLI::NilValue
      end

      it "returns id of the resource" do
        ResourceMocks.mock_action_call(:users, :index, [john])

        resolver_run.call.must_equal john_id
      end

    end

    describe "searching dependent resources" do
      let(:resolver_run) { proc { resolver.post_id({"option_name" => "Post 11", "option_user_name" => "John Doe"}) } }

      it "raises exception when no resource is found" do
        ResourceMocks.mock_action_call(:posts, :index, [])
        ResourceMocks.mock_action_call(:users, :index, [])

        err = resolver_run.must_raise HammerCLIForeman::ResolverError
        err.message.must_equal "user not found."
      end

      it "raises exception when multiple resources are found" do
        ResourceMocks.mock_action_call(:posts, :index, [])
        ResourceMocks.mock_action_call(:users, :index, [john, jane])

        err = resolver_run.must_raise HammerCLIForeman::ResolverError
        err.message.must_equal "Found more than one user."
      end

      it "calls index action with appropriate search params" do
        ApipieBindings::API.any_instance.expects(:call).with() do |resource, action, params, headers, opts|
          ( resource == :users &&
            action == :index &&
            params[:search] == "name = \"John Doe\"")
        end.returns(john)

        ApipieBindings::API.any_instance.expects(:call).with() do |resource, action, params, headers, opts|
          ( resource == :posts &&
            action == :index &&
            params[:search] == "name = \"Post 11\"")
        end.returns({"id" => 11, "name" => "Post 11"})

        resolver_run.call
      end

      it "returns id of the resource" do
        ResourceMocks.mock_action_call(:posts, :index, [
          {"id" => 11, "name" => "Post 11"}
        ])
        ResourceMocks.mock_action_call(:users, :index, [
          {"id" => 22, "name" => "User 22"}
        ])
        resolver_run.call.must_equal 11
      end
    end

    describe 'searching for puppetclasses' do
      before do
        ResourceMocks.mock_action_call(:puppetclasses, :index, {
          'apache' => [
            { 'id' => 70, 'name' => 'apache::dev', 'created_at' => '2015-01-27T07:24:57.134Z', 'updated_at' => '2015-03-05T17:27:54.282Z' },
            { 'id' => 27, 'name' => 'apache::mod::authnz_ldap', 'created_at' => '2015-01-27T07:24:56.378Z','updated_at' => '2015-01-27T07:24:56.378Z' }
          ],
          'git' => [
            { 'id' => 85, 'name' => 'git::params', 'created_at' => '2015-01-27T07:24:57.306Z', 'updated_at' => '2015-01-27T07:24:57.306Z' }
          ]
        })
      end

      it "returns ids from options" do
        result = resolver.user_ids({"option_ids" => [4, 5], "option_names" => ['apache::dev']})
        assert_equal [4, 5], result
      end

      it "returns ids of the classes" do
        class_names = ['apache::mod::authnz_ldap', 'git::params', 'apache::dev']
        assert_equal [70, 27, 85], resolver.puppetclass_ids('option_names' => class_names)
      end

      it 'returns empty array for empty class array' do
        assert_equal [], resolver.puppetclass_ids('option_names' => [])
      end
    end

    describe "searching for multiple resources" do
      it "returns ids from options" do
        result = resolver.user_ids({"option_ids" => [4, 5], "option_names" => ["some", "names"]})
        assert_equal [4, 5], result
      end

      it "finds multiple ids" do
        ApipieBindings::API.any_instance.expects(:call).with() do |resource, action, params, headers, opts|
          ( resource == :users &&
            action == :index &&
            params[:search] == "name = \"John Doe\" or name = \"Jane Doe\"")
        end.returns([john, jane])

        assert_equal [john_id, jane_id], resolver.user_ids({"option_names" => ["John Doe", "Jane Doe"]})
      end

      it "raises exception when wrong number of resources is found" do
        ResourceMocks.mock_action_call(:users, :index, [john])

        assert_raises HammerCLIForeman::ResolverError do
          resolver.user_ids({"option_names" => ["John Doe", "Jane Doe"]})
        end
      end

      it "raises exception when no search options were set" do
        ResourceMocks.mock_action_call(:users, :index, [john])

        assert_raises HammerCLIForeman::MissingSearchOptions do
          resolver.user_ids({})
        end
      end

      it "returns empty array for empty input" do
        ResourceMocks.mock_action_call(:users, :index, [john, jane])

        assert_equal [], resolver.user_ids({"option_names" => []})
      end

      it "returns NilValue when the search name is NilValue" do
        resolver.user_ids({"option_names" => HammerCLI::NilValue}).must_equal HammerCLI::NilValue
      end
    end
  end
end
