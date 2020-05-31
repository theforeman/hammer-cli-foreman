require File.join(File.dirname(__FILE__), '../apipie_resource_mock')

module ResourceDisabled

  def it_should_fail_when_disabled
    arguments = @with_params ? @with_params.dup : []
    context "resource disabled" do

      it "should return error" do
        cmd.class.resource.stubs(:call).raises(RestClient::ResourceNotFound)
        arguments = respond_to?(:with_params) ? with_params : []
        _(cmd.run(arguments)).must_equal HammerCLI::EX_UNAVAILABLE
      end

      it "should print error message" do
        cmd.class.resource.stubs(:call).raises(RestClient::ResourceNotFound)
        cmd.stubs(:context).returns(ctx.update(:adapter => :test))

        arguments = respond_to?(:with_params) ? with_params : []
        _(lambda { cmd.run(arguments) }).must_output "", /.*not support.*/
      end
    end
  end
end
