# frozen_string_literal: true

module HammerCLIForeman
  module CommandExtensions
    class UpdateCommon < HammerCLI::CommandExtensions
      inheritable true

      request_params do |params, command_object|
        update_params = params[command_object.resource.singular_name]
        update_params =  update_params.nil? ? params : update_params.values.select { | val| !val.nil?}
        command_object.context[:action_message] = :nothing_to_do unless valid?(update_params)
      end

      def self.valid?(params)
        params.nil? ? false : !(params.empty? || params.select { | param | param.is_a?(Hash) && param.empty? }.count == params.count)
      end
    end
  end
end
