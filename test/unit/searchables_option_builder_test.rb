require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'helpers/fake_searchables')



describe HammerCLIForeman::SearchablesOptionBuilder do

  let(:resource) { HammerCLIForeman.foreman_resource(:architectures) }
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

  let(:resource) { HammerCLIForeman.foreman_resource(:architectures) }
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


  describe "multiple resources" do

    let(:resource) { [
      HammerCLIForeman.foreman_resource(:architectures),
      HammerCLIForeman.foreman_resource(:domains)
    ] }
    let(:searchables) { FakeSearchables.new(["name", "label"]) }

    it "builds options for all resources" do
      options.map(&:switches).must_equal [
        ["--architecture"],       # first option does not have the suffix
        ["--architecture-label"], # other options with suffixes
        ["--architecture-id"],    # additional id
        ["--domain"],       # first option does not have the suffix
        ["--domain-label"], # other options with suffixes
        ["--domain-id"]     # additional id
      ]
    end

    it "none of the options is required" do
      options.any?{|opt| opt.required? }.must_equal false
    end

  end

end


describe HammerCLIForeman::SearchablesUpdateOptionBuilder do

  let(:resource) { HammerCLIForeman.foreman_resource(:architectures) }
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
