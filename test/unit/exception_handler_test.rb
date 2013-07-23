require_relative 'test_helper'
require 'hammer_cli_foreman/exception_handler'

describe HammerCLIForeman::ExceptionHandler do

  let(:output) { HammerCLI::Output::Output.new }
  let(:handler) { HammerCLIForeman::ExceptionHandler.new :output => output }
  let(:heading) { "Something went wrong" }

  it "should print resource errors on unprocessable entity exception" do
   response = <<-RESPONSE
   {"subnet":{"id":null,"errors":{"network":["can't be blank","is invalid"],"name":["can't be blank"]},"full_messages":["Network address can't be blank","Network address is invalid","Name can't be blank"]}}
   RESPONSE

    ex = RestClient::UnprocessableEntity.new(response)
    output.expects(:print_error).with(heading, "Network address can't be blank\nNetwork address is invalid\nName can't be blank")
    handler.handle_exception(ex, :heading => heading)
  end

  it "should handle argument error" do
    ex = ArgumentError.new
    output.expects(:print_error).with(heading, ex.message)
    handler.handle_exception(ex, :heading => heading)
  end

end

