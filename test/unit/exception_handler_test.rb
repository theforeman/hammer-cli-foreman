require File.join(File.dirname(__FILE__), 'test_helper')
require 'hammer_cli_foreman/exception_handler'

describe HammerCLIForeman::ExceptionHandler do

  let(:output)  { HammerCLI::Output::Output }
  let(:handler) { HammerCLIForeman::ExceptionHandler.new }
  let(:heading) { "Something went wrong" }

  it "should print resource errors on unprocessable entity exception" do
   response = <<-RESPONSE
   {"subnet":{"id":null,"errors":{"network":["can't be blank","is invalid"],"name":["can't be blank"]},"full_messages":["Network address can't be blank","Network address is invalid","Name can't be blank"]}}
   RESPONSE

    ex = RestClient::UnprocessableEntity.new(response)
    output.expects(:print_error).with(heading, "Network address can't be blank\nNetwork address is invalid\nName can't be blank", {}, {:adapter => :base})
    handler.handle_exception(ex, :heading => heading)
  end

  it "should handle argument error" do
    ex = ArgumentError.new
    output.expects(:print_error).with(heading, ex.message, {}, {:adapter => :base})
    handler.handle_exception(ex, :heading => heading)
  end

  it "should handle forbidden error" do
    ex = RestClient::Forbidden.new
    output.expects(:print_error).with('Forbidden - server refused to process the request', nil, {}, {:adapter => :base})
    handler.handle_exception(ex)
  end

  it "should handle unknown exception" do
    output.expects(:print_error).with(heading, "Error: message", {}, {:adapter => :base})
    MyException = Class.new(Exception)
    handler.handle_exception(MyException.new('message'), :heading => heading)
  end
end

