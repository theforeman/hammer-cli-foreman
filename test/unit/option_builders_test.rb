require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'helpers/fake_searchables')

describe HammerCLIForeman::BuildParams do

  let(:params) { HammerCLIForeman::BuildParams.new }

  it "creates empty hash by default" do
    params.to_hash.must_equal( {} )
  end

  it "can be prefonfigured" do
    preconfigured_params = HammerCLIForeman::BuildParams.new(:expand => {:only => [:a, :b]}, :without => [:c, :d])
    preconfigured_params.expand.including(:c, :d)
    preconfigured_params.to_hash.must_equal( {:expand => {:only => [:a, :b], :including => [:c, :d]}, :without => [:c, :d]} )
  end

  describe "without" do

    it "sets :without" do
      params.without(:organization_id, :location_id)
      params.to_hash.must_equal( {:without => [:organization_id, :location_id]} )
    end

  end

  describe "expand" do

    it "can set expand all" do
      params.expand(:all)
      params.to_hash.must_equal( {:expand => {}} )
    end

    it "expands all by default" do
      params.expand
      params.to_hash.must_equal( {:expand => {}} )
    end

    it "can disable expansion" do
      params.expand(:none)
      params.to_hash.must_equal( {:expand => {:only => []}} )
    end

    describe "except" do
      it "sets except field" do
        params.expand.except(:organizations)
        params.to_hash.must_equal( {:expand => {:except => [:organizations]}} )
      end
    end

    describe "including" do
      it "sets including field" do
        params.expand.including(:organizations)
        params.to_hash.must_equal( {:expand => {:including => [:organizations]}} )
      end
    end

    describe "only" do
      it "sets only field" do
        params.expand.only(:organizations)
        params.to_hash.must_equal( {:expand => {:only => [:organizations]}} )
      end
    end

    describe "primary" do
      it "sets primary field" do
        params.expand.primary(:organizations)
        params.to_hash.must_equal( {:expand => {:primary => :organizations}} )
      end
    end

  end

end

describe HammerCLIForeman::BuilderConfigurator do

  let(:api) do ApipieBindings::API.new({
    :apidoc_cache_dir => 'test/unit/data',
    :apidoc_cache_name => 'test_api',
    :dry_run => true})
  end
  let(:resource) { api.resource(:users) }
  let(:action) { resource.action(:index)}

  let(:searchables) { FakeSearchables.new(["name", "label"]) }
  let(:resolver) { HammerCLIForeman::DependencyResolver.new }
  let(:configurator) { HammerCLIForeman::BuilderConfigurator.new(searchables, resolver) }

  let(:result_builders) { configurator.builders_for(resource, action) }
  let(:result_classes) { result_builders.map(&:class) }

  def builders_by_class(cls)
    result_builders.select {|b| b.class == cls}
  end

  def resource_names(builders)
    builders.map(&:resource).map(&:name)
  end

  describe "simple action without ids" do

    let(:action) { resource.action(:index)}

    it "adds no option builder" do
      result_classes.must_equal []
    end
  end

  describe "simple show action without dependent resources" do

    let(:action) { resource.action(:show)}

    it "adds searchable options builder" do
      resource_names(builders_by_class(HammerCLIForeman::SearchablesOptionBuilder)).must_equal [:users]
    end
  end

  describe "action with dependent resources" do

    let(:resource) { api.resource(:posts) }
    let(:action) { resource.action(:show)}

    it "adds searchable options builder" do
      resource_names(builders_by_class(HammerCLIForeman::SearchablesOptionBuilder)).must_equal [:posts]
    end

    it "adds dependent searchable option builders" do
      resources = resource_names(builders_by_class(HammerCLIForeman::DependentSearchablesOptionBuilder)).sort
      expected = [:users]
      resources.must_equal expected.sort
    end

  end

end

describe HammerCLIForeman::ForemanOptionBuilder do

  let(:api) do ApipieBindings::API.new({
    :apidoc_cache_dir => 'test/unit/data',
    :apidoc_cache_name => 'test_api',
    :dry_run => true})
  end

  let(:options) {
    [
      HammerCLI::Options::OptionDefinition.new(["--test"], "TEST", "test"),
      HammerCLI::Options::OptionDefinition.new(["--test2"], "TEST2", "test2")
    ]
  }
  let(:searchables) { FakeSearchables.new(["name", "label"]) }
  let(:container) { HammerCLIForeman::ForemanOptionBuilder.new(searchables) }
  let(:builder_classes) { container.builders.map(&:class) }

  before :each do
    HammerCLIForeman.stubs(:foreman_api).returns(api)
  end

  it "collects options from contained builders" do
    builder = Object.new
    builder.stubs(:build).returns(options)

    container.builders = [builder, builder]
    container.build.must_equal options+options
  end

  it "passes build parameters to contained builders" do
    params = {:param => :value}
    builder = Object.new
    builder.expects(:build).with(params).returns(options)

    container.builders = [builder]
    container.build(params)
  end


  context "primary searchables options expansion" do
    let(:option_switches) { container.build(@build_options).map(&:switches) }

    it "can remove original searchable builder" do
      container.builders = [
        HammerCLIForeman::SearchablesOptionBuilder.new(api.resource(:users), FakeSearchables.new(["aaa", "bbb"]))
      ]
      @build_options = {:expand => {:primary => false}}
      option_switches.must_equal []
    end

    it "can add custom searchable builder" do
      container.builders = []
      @build_options = {:expand => {:primary => :users}}
      option_switches.must_equal [
        ["--name"],
        ["--label"]
      ]
    end

    it "can replace original searchable builder with a custom one" do
      container.builders = [
        HammerCLIForeman::SearchablesOptionBuilder.new(api.resource(:posts), FakeSearchables.new(["aaa", "bbb"]))
      ]
      @build_options = {:expand => {:primary => :users}}
      option_switches.must_equal [
        ["--name"],
        ["--label"]
      ]
    end

  end

  context "dependent searchables options expansion" do
    let(:option_switches) { container.build(@build_options).map(&:switches) }

    before :each do
      container.builders = [
        HammerCLIForeman::DependentSearchablesOptionBuilder.new(api.resource(:users), searchables),
        HammerCLIForeman::DependentSearchablesOptionBuilder.new(api.resource(:posts), searchables)
      ]
    end

    it "does not filter searchable builders by default" do
      @build_options = {:expand => {}}
      option_switches.must_equal [
        ["--user"],
        ["--user-label"],
        ["--user-id"],
        ["--post"],
        ["--post-label"],
        ["--post-id"]
      ]
    end

    it "adds dependent searchable builders on explicit requirement" do
      @build_options = {:expand => {:including => [:posts, :comments]}}
      option_switches.must_equal [
        ["--user"],
        ["--user-label"],
        ["--user-id"],
        ["--post"],
        ["--post-label"],
        ["--post-id"],
        ["--comment"],
        ["--comment-label"],
        ["--comment-id"]
      ]
    end

    it "filters dependent searchable builders on explicit requirement" do
      @build_options = {:expand => {:except => [:users]}}
      option_switches.must_equal [
        ["--post"],
        ["--post-label"],
        ["--post-id"]
      ]
    end

    it "specifies custom set of dependent searchable builders on explicit requirement" do
      @build_options = {:expand => {:only => [:comments, :users]}}
      option_switches.must_equal [
        ["--user"],
        ["--user-label"],
        ["--user-id"],
        ["--comment"],
        ["--comment-label"],
        ["--comment-id"]
      ]
    end
  end
end


describe HammerCLIForeman::SearchablesOptionBuilder do

  let(:api) do ApipieBindings::API.new({
    :apidoc_cache_dir => 'test/unit/data',
    :apidoc_cache_name => 'test_api',
    :dry_run => true})
  end
  let(:resource) { api.resource(:users) }
  let(:searchables) { FakeSearchables.new(["name", "label"]) }
  let(:builder) { HammerCLIForeman::SearchablesOptionBuilder.new(resource, searchables) }
  let(:options) { builder.build }

  describe "empty searchables" do
    let(:searchables) { FakeSearchables.new([]) }

    it "builds no options for empty searchables" do
      options.must_equal []
    end
  end

  describe "multiple searchables" do

    it "builds correct switches" do
      options.map(&:switches).must_equal [["--name"], ["--label"]]
    end

    it "builds correct descriptions" do
      options.map(&:description).must_equal ["Search by name", "Search by label"]
    end

    it "builds correct types" do
      options.map(&:type).must_equal ["NAME", "LABEL"]
    end

    it "builds correct attribute readers" do
      options.map(&:read_method).must_equal [
        "option_name",
        "option_label"
      ]
    end

    it "none of the options is required" do
      options.any?{|opt| opt.required? }.must_equal false
    end
  end
end


describe HammerCLIForeman::DependentSearchablesOptionBuilder do

  let(:api) do ApipieBindings::API.new({
    :apidoc_cache_dir => 'test/unit/data',
    :apidoc_cache_name => 'test_api',
    :dry_run => true})
  end
  let(:resource) { api.resource(:users) }
  let(:searchables) { FakeSearchables.new(["name", "label", "uuid"]) }
  let(:builder) { HammerCLIForeman::DependentSearchablesOptionBuilder.new(resource, searchables) }
  let(:builder_params) { {} }
  let(:options) { builder.build(builder_params) }

  describe "empty searchables" do

    let(:searchables) { FakeSearchables.new([]) }

    it "builds only id options" do
      options.map(&:switches).must_equal [["--user-id"]]
    end
  end

  describe "multiple searchables" do

    it "creates correct switches" do
      options.map(&:switches).must_equal [
        ["--user"],       # first option does not have the suffix
        ["--user-label"], # other options with suffixes
        ["--user-uuid"],
        ["--user-id"]     # additional id
      ]
    end

    it "creates correct option types" do
      options.map(&:type).must_equal [
        "USER_NAME",
        "USER_LABEL",
        "USER_UUID",
        "USER_ID",
      ]
    end

    it "creates correct descriptions" do
      options.map(&:description).must_equal [
        "Search by name",
        "Search by label",
        "Search by uuid",
        "DESC"
      ]
    end

    it "creates correct attribute readers" do
      options.map(&:read_method).must_equal [
        "option_user_name",
        "option_user_label",
        "option_user_uuid",
        "option_user_id",
      ]
    end

    it "none of the options is required" do
      options.any?{|opt| opt.required? }.must_equal false
    end
  end


  describe "aliasing resource names" do

    let(:builder_params) { {:resource_mapping => {:user => :usr}} }

    it "renames options" do
      options.map(&:switches).must_equal [
        ["--usr"],       # first option does not have the suffix
        ["--usr-label"], # other options with suffixes
        ["--usr-uuid"],
        ["--usr-id"]     # additional id
      ]
    end

    it "renames option types" do
      options.map(&:type).must_equal [
        "USR_NAME",
        "USR_LABEL",
        "USR_UUID",
        "USR_ID",
      ]
    end

    it "keeps option accessor the same" do
      options.map(&:attribute_name).must_equal [
        "option_user_name",
        "option_user_label",
        "option_user_uuid",
        "option_user_id"
      ]
    end
  end

  describe "resources with id parameter in show action" do

    it "uses descriptions from the action" do
      options.map(&:description).must_equal [
        "Search by name",
        "Search by label",
        "Search by uuid",
        "DESC"
      ]
    end
  end
end

describe HammerCLIForeman::SearchablesUpdateOptionBuilder do
  let(:api) do ApipieBindings::API.new({
    :apidoc_cache_dir => 'test/unit/data',
    :apidoc_cache_name => 'test_api',
    :dry_run => true})
  end
  let(:resource) { api.resource(:users) }
  let(:searchables) { FakeSearchables.new(["name"], ["label"]) }
  let(:builder) { HammerCLIForeman::SearchablesUpdateOptionBuilder.new(resource, searchables) }
  let(:options) { builder.build }

  describe "empty searchables" do
    let(:searchables) { FakeSearchables.new([]) }

    it "builds no options for empty searchables" do
      options.must_equal []
    end
  end

  describe "multiple searchables" do

    it "builds correct switches" do
      options.map(&:switches).must_equal [["--new-label"]]
    end

    it "builds correct descriptions" do
      options.map(&:description).must_equal [" "]
    end

    it "builds correct types" do
      options.map(&:type).must_equal ["NEW_LABEL"]
    end

    it "builds correct attribute readers" do
      options.map(&:read_method).must_equal [
        "option_new_label"
      ]
    end

    it "none of the options is required" do
      options.any?{|opt| opt.required? }.must_equal false
    end
  end

  describe "resources with corresponding parameter in update action" do

    before :each do
      label_param = Object.new
      label_param.stubs(:name).returns("label")
      label_param.stubs(:params).returns([])
      label_param.stubs(:description).returns("DESC")

      action = Object.new
      action.stubs(:params).returns([label_param])

      resource.stubs(:action).with(:update).returns(action)
    end

    it "uses descriptions from the action" do
      options.map(&:description).must_equal ["DESC"]
    end
  end
end

describe HammerCLIForeman::IdOptionBuilder do
  let(:api) do ApipieBindings::API.new({
    :apidoc_cache_dir => 'test/unit/data',
    :apidoc_cache_name => 'test_api',
    :dry_run => true})
  end
  let(:resource) { api.resource(:users) }
  let(:builder) { HammerCLIForeman::IdOptionBuilder.new(resource) }
  let(:options) { builder.build }

  describe "resources with parameter :id in show action" do
    it "creates options --id" do
      options.map(&:switches).must_equal [["--id"]]
    end

    it "uses description from the :id param" do
      options.map(&:description).must_equal ["DESC"]
    end
  end

  describe "resources without parameter :id in show action" do

    before :each do
      action = Object.new
      action.stubs(:params).returns([])

      resource.stubs(:action).with(:show).returns(action)
    end

    it "creates options --id" do
      options.map(&:switches).must_equal [["--id"]]
    end

    it "uses empty description" do
      options.map(&:description).must_equal [" "]
    end
  end

end
