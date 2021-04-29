module HammerCLIForeman

  class SmartProxy < HammerCLIForeman::Command

    resource :smart_proxies

    class ListCommand < HammerCLIForeman::ListCommand

      #FIXME: search by unknown type returns 500 from the server, propper error handling should resove this
      output do
        field :id, _("Id")
        field :name, _("Name")
        field :url, _("URL")
        field :_features, _( "Features"), Fields::List, :width => 25, :hide_blank => true
      end

      def extend_data(proxy)
        proxy['_features'] = proxy['features'].map { |f| f['name'] } if proxy['features']
        proxy
      end

      build_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand

      output ListCommand.output_definition do
        collection :features,  _("Features"), :numbered => false do
          custom_field Fields::Reference
        end
        HammerCLIForeman::References.taxonomies(self)
        HammerCLIForeman::References.timestamps(self)
      end

      build_options
    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      success_message _("Smart proxy created.")
      failure_message _("Could not create the proxy")

      build_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      success_message _("Smart proxy updated.")
      failure_message _("Could not update the proxy")

      build_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      success_message _("Smart proxy deleted.")
      failure_message _("Could not delete the proxy")

      build_options
    end


    class ImportPuppetClassesCommand < HammerCLIForeman::Command
      action :import_puppetclasses

      command_name    "import-classes"

      option "--dryrun", :flag, _("Do not run the import")

      output do
        field :message, _("Result"), Fields::LongText
        collection :results, _("Changed environments"), :hide_blank => true do
          field :name, nil
          collection :new_puppetclasses, _("New classes"), :hide_blank => true, :numbered => false do
            field nil, nil
          end
          collection :updated_puppetclasses, _("Updated classes"), :hide_blank => true, :numbered => false do
            field nil, nil
          end
          collection :obsolete_puppetclasses, _("Removed classes"), :hide_blank => true, :numbered => false do
            field nil, nil
          end
          collection :ignored_puppetclasses, _("Ignored classes"), :hide_blank => true, :numbered => false do
            field nil, nil
          end
        end
      end

      build_options do |o|
        o.without(:smart_proxy_id, :dryrun)
        o.expand.except(:smart_proxies)
      end

      def request_params
        opts = super
        opts['dryrun'] = option_dryrun? || false
        opts
      end

      def transform_format(data)
        # Overriding the default behavior that tries to remove nesting
        # when there's only {"message": "..."}
        data
      end

      def print_data(record)
        print_record(output_definition, record)
      end

    end


    class RefreshFeaturesCommand < HammerCLIForeman::Command

      action :refresh

      command_name    "refresh-features"
      success_message _("Smart proxy features were refreshed.")
      failure_message _("Refresh of smart proxy features failed")

      build_options
    end

    autoload_subcommands
  end

end
