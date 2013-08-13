require File.join(File.dirname(__FILE__), '../apipie_resource_mock')

module ResourceDisabled

  def it_should_fail_when_disabled
    arguments = @with_params ? @with_params.dup : []
    context "resource disabled" do

      it "should return error" do
        cmd.class.resource ApipieDisabledResourceMock.new(cmd.class.resource)
        arguments = respond_to?(:with_params) ? with_params : []
        cmd.run(arguments).must_equal 1
      end

      it "should print error message" do
        cmd.class.resource ApipieDisabledResourceMock.new(cmd.class.resource)
        cmd.output.adapter = TestAdapter.new
        arguments = respond_to?(:with_params) ? with_params : []
        lambda { cmd.run(arguments) }.must_output "", /.*not support.*/
      end
    end
  end
end
