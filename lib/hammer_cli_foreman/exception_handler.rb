require 'hammer_cli/exception_handler'

module HammerCLIForeman
  class ExceptionHandler < HammerCLI::ExceptionHandler

    def mappings
      {
        RestClient::UnprocessableEntity => :handle_unprocessable_entity,
        ArgumentError => :handle_argument_error
      }.merge super
    end

    protected

    def handle_unprocessable_entity e
      response = JSON.parse(e.response)
      response = response[response.keys[0]]

      print_error response["full_messages"]
      return 83
    end


    def handle_argument_error e
      print_error e.message
      return 83
    end

  end
end



