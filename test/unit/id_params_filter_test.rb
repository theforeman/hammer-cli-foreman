require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')
require File.join(File.dirname(__FILE__), 'helpers/fake_searchables')

describe HammerCLIForeman::IdParamsFilter do

  let(:filter) { HammerCLIForeman::IdParamsFilter.new }


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
      filter.for_action(action, :only_required => true).must_equal required_params
    end

    it "returns only ending with _id when :only_required is set to false" do
      filter.for_action(action, :only_required => false).must_equal (required_params+id_params)
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
        filter.for_action(action, :only_required => true).must_equal required_params
      end

      it "returns only ending with _id when :only_required is set to false" do
        filter.for_action(action, :only_required => false).must_equal (required_params+id_params)
      end

    end
  end

end
