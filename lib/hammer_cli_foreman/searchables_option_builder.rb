
module HammerCLIForeman

  class SearchablesOptionBuilder < HammerCLI::AbstractOptionBuilder

    def initialize(resource, searchables)
      @resource = resource
      @searchables = searchables
    end

    def build(builder_params={})
      @searchables.for(@resource).collect do |s|
        option(
          optionamize("--#{s.name}"),
          s.name.upcase,
          s.description
        )
      end
    end
  end


  class DependentSearchablesOptionBuilder < HammerCLI::AbstractOptionBuilder

    def initialize(dependent_resources, searchables)
      @dependent_resources = dependent_resources.is_a?(Array) ? dependent_resources : [dependent_resources]
      @searchables = searchables
    end


    def build(builder_params={})
      @dependent_resources.collect do |res|
        dependent_options(res)
      end.flatten(1)
    end

    def dependent_options(resource)
      options = []
      searchables = @searchables.for(resource)
      resource_name = resource.singular_name

      unless searchables.empty?
        first = searchables[0]
        remaining = searchables[1..-1] || []

        # First option is named by the resource
        # Eg. --organization with accessor option_organization_name
        options << option(
          optionamize("--#{resource_name}"),
          "#{resource_name}_#{first.name}".upcase,
          " ",
          :attribute_name => HammerCLI.option_accessor_name("#{resource_name}_#{first.name}")
        )

        # Other options are named by the resource plus the searchable name
        # Eg. --organization-label with accessor option_organization_label
        remaining.each do |s|
          options << option(
            optionamize("--#{resource_name}-#{s.name}"),
            "#{resource_name}_#{s.name}".upcase,
            " "
          )
        end
      end

      options << option(
        optionamize("--#{resource_name}-id"),
        "#{resource_name}_id".upcase,
        " "
      )
      options
    end

  end

  class SearchablesUpdateOptionBuilder < HammerCLI::AbstractOptionBuilder

    def initialize(resource, searchables)
      @resource = resource
      @searchables = searchables
    end

    def build(builder_params={})

      @searchables.for(@resource).collect do |s|
        if s.editable?
          option(
            optionamize("--new-#{s.name}"),
            "NEW_#{s.name.upcase}",
            " "
          )
        end
      end.compact
    end

  end


end
