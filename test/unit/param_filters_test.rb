require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')
require File.join(File.dirname(__FILE__), 'helpers/fake_searchables')

describe HammerCLIForeman::ParamsFlattener do

  let(:flattener) { HammerCLIForeman::ParamsFlattener.new }

  let(:param1) {
    stub(:name => "param1", :params => [])
  }
  let(:param2) {
    stub(:name => "param1", :params => [])
  }
  let(:hash_param) {
    stub(:name => "object", :params => (
      [param1, param2]
    ))
  }
  let(:hash_param2) {
    stub(:name => "object", :params => (
      [param1, hash_param]
    ))
  }

  it "flatten params" do
    flattener.filter([param1, param2, hash_param2]).must_equal [param1, param2, hash_param2, param1, hash_param, param1, param2]
  end

  it "returns empty array for no params" do
    flattener.filter([]).must_equal []
  end

end


describe HammerCLIForeman::IdParamsFilter do

  let(:filter) { HammerCLIForeman::IdParamsFilter.new }
  let(:nonrequired_filter) { HammerCLIForeman::IdParamsFilter.new(:only_required => false) }
  let(:required_filter) { HammerCLIForeman::IdParamsFilter.new(:only_required => true) }

  describe "params for action" do
    let(:required_params) {[
      stub(:name => "architecture_id", :required? => true, :params => []),
      stub(:name => "organization_id", :required? => true, :params => [])
    ]}
    let(:id_params) {[
      stub(:name => "domain_id", :required? => false, :params => [])
    ]}
    let(:other_params) {[
      stub(:name => "location", :required? => true, :params => []),
      stub(:name => "param", :required? => false, :params => [])
    ]}
    let(:hash_param) {
      stub(:name => "object", :required? => false, :params => (
        required_params+id_params+other_params
      ))
    }

    let(:action) {
      stub(:params => (required_params+id_params+other_params))
    }

    it "returns only required params ending with _id" do
      required_filter.for_action(action).must_equal required_params
    end

    it "returns only ending with _id when :only_required is set to false" do
      nonrequired_filter.for_action(action).must_equal (required_params+id_params)
    end

    it "returns required params by default" do
      filter.for_action(action).must_equal required_params
    end

    context "with hash params" do

      let(:action) {
        stub(:params => [hash_param])
      }

      it "finds params inside a hash" do
        filter.for_action(action).must_equal required_params
      end

      it "returns only required params ending with _id" do
        required_filter.for_action(action).must_equal required_params
      end

      it "returns only ending with _id when :only_required is set to false" do
        nonrequired_filter.for_action(action).must_equal (required_params+id_params)
      end

    end
  end

end



describe HammerCLIForeman::IdArrayParamsFilter do

  let(:filter) { HammerCLIForeman::IdArrayParamsFilter.new }
  let(:nonrequired_filter) { HammerCLIForeman::IdArrayParamsFilter.new(:only_required => false) }
  let(:required_filter) { HammerCLIForeman::IdArrayParamsFilter.new(:only_required => true) }

  describe "params for action" do
    let(:required_params) {[
      stub(:name => "architecture_ids", :required? => true, :params => []),
      stub(:name => "organization_ids", :required? => true, :params => [])
    ]}
    let(:id_params) {[
      stub(:name => "domain_ids", :required? => false, :params => [])
    ]}
    let(:other_params) {[
      stub(:name => "location_id", :required? => true, :params => []),
      stub(:name => "param", :required? => false, :params => [])
    ]}
    let(:hash_param) {
      stub(:name => "object", :required? => false, :params => (
        required_params+id_params+other_params
      ))
    }

    let(:action) {
      stub(:params => (required_params+id_params+other_params))
    }

    it "returns only required params ending with _ids" do
      required_filter.for_action(action).must_equal required_params
    end

    it "returns only ending with _ids when :only_required is set to false" do
      nonrequired_filter.for_action(action).must_equal (required_params+id_params)
    end

    it "returns required params by default" do
      filter.for_action(action).must_equal required_params
    end

    context "with hash params" do

      let(:action) {
        stub(:params => [hash_param])
      }

      it "finds params inside a hash" do
        filter.for_action(action).must_equal required_params
      end

      it "returns only required params ending with _ids" do
        required_filter.for_action(action).must_equal required_params
      end

      it "returns only ending with _ids when :only_required is set to false" do
        nonrequired_filter.for_action(action).must_equal (required_params+id_params)
      end

    end
  end

end




describe HammerCLIForeman::ParamsNameFilter do

  describe "params for action" do
    let(:the_param) {
      stub(:name => "xxx", :params => [])
    }
    let(:other_params) {[
      stub(:name => "param1", :params => []),
      stub(:name => "param2", :params => [])
    ]}
    let(:hash_param) {
      stub(:name => "object", :params => (
        [the_param]+other_params
      ))
    }

    let(:action) {
      stub(:params => ([the_param]+other_params))
    }

    it "finds parameter by name" do
      action = stub(:params => ([the_param]+other_params))
      filter = HammerCLIForeman::ParamsNameFilter.new("xxx")
      filter.for_action(action).must_equal [the_param]
    end

    it "finds parameter by name nested in another hash parameter" do
      action = stub(:params => ([hash_param]+other_params))
      filter = HammerCLIForeman::ParamsNameFilter.new("xxx")
      filter.for_action(action).must_equal [the_param]
    end

    it "returns empty array when the parameter is not found" do
      action = stub(:params => ([the_param]+other_params))
      filter = HammerCLIForeman::ParamsNameFilter.new("???")
      filter.for_action(action).must_equal []
    end

  end

end
