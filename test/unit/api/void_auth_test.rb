require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLIForeman::Api::VoidAuth do
  describe '#status' do
    it "returns a configured status message" do
      msg = 'Some message'
      auth = HammerCLIForeman::Api::VoidAuth.new(msg)
      assert_equal msg, auth.status
    end
  end
end
