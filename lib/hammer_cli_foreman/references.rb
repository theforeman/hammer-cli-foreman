module HammerCLIForeman

  module References


    def self.timestamps(dsl)
      dsl.build do
        field :created_at, _("Created at"), Fields::Date
        field :updated_at, _("Updated at"), Fields::Date
      end
    end

    def self.taxonomies(dsl)
      dsl.build do
        collection :locations, _("Locations"), :numbered => false, :hide_blank => true do
          custom_field Fields::Reference, :name_key => :title
        end
        collection :organizations, _("Organizations"), :numbered => false, :hide_blank => true do
          custom_field Fields::Reference, :name_key => :title
        end
      end
    end

    def self.users(dsl)
      dsl.build do
        collection :users, _("Users"), :numbered => false do
          custom_field Fields::Reference, :name_key => :login
        end
      end
    end

    def self.usergroups(dsl)
      dsl.build do
        collection :usergroups, _("User groups"), :numbered => true do
          field :name, _("Usergroup")
          field :id, _("Id"), Fields::Id
          collection :roles, _("Roles"), :numbered => false do
            custom_field Fields::Reference
          end
        end
        collection :cached_usergroups, _("Inherited User groups"), :numbered => true do
          field :name, _("Usergroup")
          field :id, _("Id"), Fields::Id
          collection :roles, _("Roles"), :numbered => false do
            custom_field Fields::Reference
          end
        end
      end
    end

    def self.smart_proxies(dsl)
      dsl.build do
        collection :smart_proxies, _("Smart proxies"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

    def self.compute_profiles(dsl)
      dsl.build do
        collection :compute_profiles, _("Compute profiles"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

    def self.compute_resources(dsl)
      dsl.build do
        collection :compute_resources, _("Compute resources"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

    def self.media(dsl)
      dsl.build do
        collection :media, _("Installation media"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

    def self.provisioning_templates(dsl)
      dsl.build do
        collection :provisioning_templates, _("Templates"), :numbered => false do
          custom_field Fields::Template
        end
      end
    end

    def self.partition_tables(dsl)
      dsl.build do
        collection :ptables, _("Partition Tables"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

    def self.domains(dsl)
      dsl.build do
        collection :domains, _("Domains"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

    def self.realms(dsl)
      dsl.build do
        collection :realms, _("Realms"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

    def self.hostgroups(dsl)
      dsl.build do
        collection :hostgroups, _("Hostgroups"), :numbered => false do
          custom_field Fields::Reference, :name_key => :title
        end
      end
    end

    def self.subnets(dsl)
      dsl.build do
        collection :subnets, _("Subnets"), :numbered => false do
          custom_field Fields::Reference, :details => :network_address
        end
      end
    end


    def self.parameters(dsl)
      dsl.build do
        collection :parameters, _("Parameters"), :numbered => false, :csv_parameter_keys => true do
          custom_field Fields::KeyValue
        end
      end
    end

    def self.all_parameters(dsl)
      dsl.build do
        collection :all_parameters, _("All parameters"), :numbered => false, :csv_parameter_keys => true do
          custom_field Fields::KeyValue
        end
      end
    end

    # CSV needs a column for every key actually returned, including keys added by
    # Foreman plugins. Build an instance-local definition only after the response.
    def self.csv_parameter_definition(definition, record)
      return definition unless definition.fields.any? { |field| field.parameters[:csv_parameter_keys] }

      copy = Marshal.load(Marshal.dump(definition))
      copy.fields.each do |collection|
        next unless collection.parameters[:csv_parameter_keys]

        data = HammerCLI::Output::Adapter::Abstract.data_for_field(collection, record)
        next if data.nil? || data.is_a?(HammerCLI::Output::DataMissing)
        raise TypeError, 'Expected a parameter collection' unless data.is_a?(Array)

        keys = data.flat_map do |entry|
          raise TypeError, 'Expected a parameter object' unless entry.is_a?(Hash)
          unless entry.keys.all? { |key| key.is_a?(String) || key.is_a?(Symbol) }
            raise TypeError, 'Expected string parameter keys'
          end
          names = entry.keys.map(&:to_s)
          raise ArgumentError, 'Ambiguous parameter keys' unless names.uniq.size == names.size
          names
        end.uniq
        collection.output_definition.clear
        keys.each do |key|
          # The original CSV parameter hash included IDs even without --show-ids.
          field = Fields::Field.new(:path => [key], :key => key, :label => key)
          field.parent = collection
          collection.output_definition.append(field)
        end
      end
      copy
    end

    def self.operating_systems(dsl)
      dsl.build do
        collection :operatingsystems, _("Operating systems"), :numbered => false do
          custom_field Fields::Reference, :name_key => :title
        end
      end
    end

    def self.roles(dsl)
      dsl.build do
        collection :roles, _("Roles"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

    def self.external_usergroups(dsl)
      dsl.build do
        collection :external_usergroups, _("External user groups"), :numbered => false do
          custom_field Fields::Reference
        end
      end
    end

  end
end
