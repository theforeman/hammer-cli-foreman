# frozen_string_literal: true

module HammerCLIForeman
  module CommandExtensions
    class UpdateCommon < HammerCLI::CommandExtensions
      inheritable true

      request_params do |params, command_object|
        update_params = params[command_object.resource.singular_name]
        command_object.context[:action_message] = :nothing_to_do if update_params && update_params.empty? && command_object.context[:action_message].nil?
      end
    end
  end
end
