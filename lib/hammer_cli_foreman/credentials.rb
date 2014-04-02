module HammerCLIForeman
  class Credentials < HammerCLI::Apipie::AbstractCredentials

    def initialize(params={})
      @username = params[:username]
      @password = params[:password]
    end

    def username
      @username ||= ask_user(_("[Foreman] username: ")) if HammerCLI.interactive?
      @username
    end

    def password
      @password ||= ask_user(_("[Foreman] password for %s: ") % @username, true) if HammerCLI.interactive?
      @password
    end

    def empty?
      !@username && !@password
    end

    def clear
      @username = nil
      @password = nil
    end

    def to_params
      {
        :username => username,
        :password => password
      }
    end

  end
end
