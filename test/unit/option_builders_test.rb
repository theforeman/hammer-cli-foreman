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

  let(:resource) { HammerCLIForeman.foreman_resource!(:operatingsystems)}
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
      resource_names(builders_by_class(HammerCLIForeman::SearchablesOptionBuilder)).must_equal [:operatingsystems]
    end

  end

  describe "action with dependent resources" do

    let(:resource) { HammerCLIForeman.foreman_resource!(:images)}
    let(:action) { HammerCLIForeman.foreman_resource!(:images).action(:show)}

    it "adds searchable options builder" do
      resource_names(builders_by_class(HammerCLIForeman::SearchablesOptionBuilder)).must_equal [:images]
    end

    it "adds dependent searchable option builders" do
      resource_names(builders_by_class(HammerCLIForeman::DependentSearchablesOptionBuilder)).must_equal [
        :compute_resources
      ]
    end

  end

end

describe HammerCLIForeman::ForemanOptionBuilder do

  let(:options) {
    [
      HammerCLI::Options::OptionDefinition.new(["--test"], "TEST", "test"),
      HammerCLI::Options::OptionDefinition.new(["--test2"], "TEST2", "test2")
    ]
  }
  let(:searchables) { FakeSearchables.new(["name", "label"]) }
  let(:container) { HammerCLIForeman::ForemanOptionBuilder.new(searchables) }
  let(:builder_classes) { container.builders.map(&:class) }


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
        HammerCLIForeman::SearchablesOptionBuilder.new(HammerCLIForeman.foreman_resource(:organizations), FakeSearchables.new(["aaa", "bbb"]))
      ]
      @build_options = {:expand => {:primary => false}}
      option_switches.must_equal []
    end

    it "can add custom searchable builder" do
      container.builders = []
      @build_options = {:expand => {:primary => :organizations}}
      option_switches.must_equal [
        ["--name"],
        ["--label"]
      ]
    end

    it "can replace original searchable builder with a custom one" do
      container.builders = [
        HammerCLIForeman::SearchablesOptionBuilder.new(HammerCLIForeman.foreman_resource(:locations), FakeSearchables.new(["aaa", "bbb"]))
      ]
      @build_options = {:expand => {:primary => :organizations}}
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
        HammerCLIForeman::DependentSearchablesOptionBuilder.new(HammerCLIForeman.foreman_resource(:organizations), searchables),
        HammerCLIForeman::DependentSearchablesOptionBuilder.new(HammerCLIForeman.foreman_resource(:locations), searchables)
      ]
    end

    it "does not filter searchable builders by default" do
      @build_options = {:expand => {}}
      option_switches.must_equal [
        ["--organization"],
        ["--organization-label"],
        ["--organization-id"],
        ["--location"],
        ["--location-label"],
        ["--location-id"]
      ]
    end

    it "adds dependent searchable builders on explicit requirement" do
      @build_options = {:expand => {:including => [:organizations, :architectures]}}
      option_switches.must_equal [
        ["--organization"],
        ["--organization-label"],
        ["--organization-id"],
        ["--location"],
        ["--location-label"],
        ["--location-id"],
        ["--architecture"],
        ["--architecture-label"],
        ["--architecture-id"]
      ]
    end

    it "filters dependent searchable builders on explicit requirement" do
      @build_options = {:expand => {:except => [:organizations]}}
      option_switches.must_equal [
        ["--location"],
        ["--location-label"],
        ["--location-id"]
      ]
    end

    it "specifies custom set of dependent searchable builders on explicit requirement" do
      @build_options = {:expand => {:only => [:architectures, :organizations]}}
      option_switches.must_equal [
        ["--organization"],
        ["--organization-label"],
        ["--organization-id"],
        ["--architecture"],
        ["--architecture-label"],
        ["--architecture-id"]
      ]
    end

  end



end


describe HammerCLIForeman::SearchablesOptionBuilder do

  let(:resource) { HammerCLIForeman.foreman_resource!(:architectures) }
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

  let(:resource) { HammerCLIForeman.foreman_resource!(:architectures) }
  let(:searchables) { FakeSearchables.new(["name", "label", "uuid"]) }
  let(:builder) { HammerCLIForeman::DependentSearchablesOptionBuilder.new(resource, searchables) }
  let(:options) { builder.build }

  describe "empty searchables" do

    let(:searchables) { FakeSearchables.new([]) }

    it "builds only id options" do
      options.map(&:switches).must_equal [["--architecture-id"]]
    end

  end


  describe "multiple searchables" do

    it "creates correct switches" do
      options.map(&:switches).must_equal [
        ["--architecture"],       # first option does not have the suffix
        ["--architecture-label"], # other options with suffixes
        ["--architecture-uuid"],
        ["--architecture-id"]     # additional id
      ]
    end

    it "creates correct option types" do
      options.map(&:type).must_equal [
        "ARCHITECTURE_NAME",
        "ARCHITECTURE_LABEL",
        "ARCHITECTURE_UUID",
        "ARCHITECTURE_ID",
      ]
    end

    it "creates correct attribute readers" do
      options.map(&:read_method).must_equal [
        "option_architecture_name",
        "option_architecture_label",
        "option_architecture_uuid",
        "option_architecture_id",
      ]
    end

    it "none of the options is required" do
      options.any?{|opt| opt.required? }.must_equal false
    end
  end

end


describe HammerCLIForeman::SearchablesUpdateOptionBuilder do

  let(:resource) { HammerCLIForeman.foreman_resource!(:architectures) }
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


end
