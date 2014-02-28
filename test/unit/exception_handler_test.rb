require File.join(File.dirname(__FILE__), 'test_helper')
require 'hammer_cli_foreman/exception_handler'

describe HammerCLIForeman::ExceptionHandler do

  let(:output)  { HammerCLI::Output::Output.new }
  let(:handler) { HammerCLIForeman::ExceptionHandler.new(:output => output) }
  let(:heading) { "Something went wrong" }

  it "should print nested resource errors on unprocessable entity exception" do
   response = <<-RESPONSE
   {"subnet":{"id":null,"errors":{"network":["can't be blank","is invalid"],"name":["can't be blank"]},"full_messages":["Network address can't be blank","Network address is invalid","Name can't be blank"]}}
   RESPONSE

    ex = RestClient::UnprocessableEntity.new(response)
    output.expects(:print_error).with(heading, "Network address can't be blank\nNetwork address is invalid\nName can't be blank")
    err_code = handler.handle_exception(ex, :heading => heading)
    err_code.must_equal HammerCLI::EX_DATAERR
  end

  it "should print resource errors on unprocessable entity exception" do
   response = <<-RESPONSE
   {"error":{"id":null,"errors":{"network":["can't be blank","is invalid"],"name":["can't be blank"]},"full_messages":["Network address can't be blank","Network address is invalid","Name can't be blank"]}}
   RESPONSE

    ex = RestClient::UnprocessableEntity.new(response)
    output.expects(:print_error).with(heading, "Network address can't be blank\nNetwork address is invalid\nName can't be blank")
    err_code = handler.handle_exception(ex, :heading => heading)
    err_code.must_equal HammerCLI::EX_DATAERR
  end

  it "should handle argument error" do
    ex = ArgumentError.new
    output.expects(:print_error).with(heading, ex.message)
    err_code = handler.handle_exception(ex, :heading => heading)
    err_code.must_equal HammerCLI::EX_USAGE
  end

  it "should handle forbidden error" do
    ex = RestClient::Forbidden.new
    output.expects(:print_error).with('Forbidden - server refused to process the request', nil)
    err_code = handler.handle_exception(ex)
    err_code.must_equal HammerCLI::EX_NOPERM
  end

  it "should handle unknown exception" do
    output.expects(:print_error).with(heading, "Error: message")
    MyException = Class.new(Exception)
    err_code = handler.handle_exception(MyException.new('message'), :heading => heading)
    err_code.must_equal HammerCLI::EX_SOFTWARE
  end

  it "should handle unsupported operation error" do
    output.expects(:print_error).with(heading, "message")
    err_code = handler.handle_exception(HammerCLIForeman::OperationNotSupportedError.new('message'), :heading => heading)
    err_code.must_equal HammerCLI::EX_UNAVAILABLE
  end

  it "should print resource errors on resource not found exception" do
    response = <<-RESPONSE
    {"error":{"message":"Resource architecture not found by id '1'"}}
    RESPONSE
    ex = RestClient::ResourceNotFound.new(response)
    ex.stubs(:message).returns("")

    output.expects(:print_error).with(heading, "Resource architecture not found by id '1'")
    err_code = handler.handle_exception(ex, :heading => heading)
    err_code.must_equal HammerCLI::EX_NOT_FOUND
  end

  it "should print exception message on resource not found exception without explicit message" do
    response = '{"error": ""}'
    ex = RestClient::ResourceNotFound.new(response)
    ex.stubs(:message).returns("ResourceNotFound message")

    output.expects(:print_error).with(heading, "ResourceNotFound message")
    err_code = handler.handle_exception(ex, :heading => heading)
    err_code.must_equal HammerCLI::EX_NOT_FOUND
  end

  it "should print resource errors on internal error exception" do
    response = <<-RESPONSE
    {"error":{"message":"Some internal exception"}}
    RESPONSE
    ex = RestClient::InternalServerError.new(response)
    ex.stubs(:message).returns("")

    output.expects(:print_error).with(heading, "Some internal exception")
    err_code = handler.handle_exception(ex, :heading => heading)
    err_code.must_equal HammerCLI::EX_SOFTWARE
  end

  it "should print exception message on internal error exception without formatted message" do
    response = <<-RESPONSE.gsub(/^\s+/, "")
    Unformatted
    lines
    RESPONSE
    ex = RestClient::InternalServerError.new(response)
    ex.stubs(:message).returns(response)

    output.expects(:print_error).with("Something went wrong", "Unformatted\nlines\n")
    err_code = handler.handle_exception(ex, :heading => heading)
    err_code.must_equal HammerCLI::EX_SOFTWARE
  end

end

