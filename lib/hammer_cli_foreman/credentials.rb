require 'highline/import'
module HammerCLIForeman
  class BasicCredentials < ApipieBindings::AbstractCredentials

    # Can keep username and passwords credentials and prompt for them when necessary
    # @param [Hash] params
    # @option params [String] :username when nil, user is prompted when the attribute is accessed
    # @option params [String] :password when nil, user is prompted when the attribute is accessed
    # @example use container with prompt
    #   c = HammerCLIForeman::BasicCredentials.new()
    #   c.username
    #   > [Foreman] Username: admin
    #   => "admin"
    # @example use container with preset value
    #   c = HammerCLIForeman::BasicCredentials.new(:username => 'admin')
    #   c.username
    #   => "admin"
    def initialize(params={})
      @username = params[:username]
      @password = params[:password]
    end

    # Get username. Prompt for it when not set
    # @return [String]
    def username
      @username ||= ask_user(_("[Foreman] Username: ")) if HammerCLI.interactive?
      @username
    end

    # Get password. Prompt for it when not set. Password characters are replaced with asterisks on the screen.
    # @return [String]
    def password
      @password ||= ask_user(_("[Foreman] Password for %s: ") % username, true) if HammerCLI.interactive?
      @password
    end

    def empty?
      !@username && !@password
    end

    def clear
      super
      @username = nil
      @password = nil
    end

    # Convert credentials to hash usable for merging to RestClient configuration.
    # @return [Hash]
    def to_params
      {
        :user => username,
        :password => password
      }
    end

    private

    def ask_user(prompt, silent=false)
      if silent
        ask(prompt) {|q| q.echo = false}
      else
        ask(prompt)
      end
    end

  end
end
