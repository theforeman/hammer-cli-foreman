module HammerCLIForeman

  class BuildParams

    class ExpansionParams

      def initialize(params={})
        @params = params || {}
      end

      def except(*resource_names)
        @params[:except] = resource_names
        self
      end

      def including(*resource_names)
        @params[:including] = resource_names
        self
      end

      def only(*resource_names)
        @params[:only] = resource_names
        self
      end

      def primary(resource_name)
        @params[:primary] = resource_name
        self
      end

      def to_hash
        @params
      end
    end


    def initialize(params={})
      @params = params || {}
    end

    def without(*option_names)
      @params[:without] = option_names
    end

    def expand(switch = :all)
      @expansion ||= ExpansionParams.new(@params[:expand])
      if (switch == :none)
        @expansion.only()
      end
      @expansion
    end

    def to_hash
      @params[:expand] = @expansion.to_hash if @expansion
      @params
    end

  end

  class BuilderConfigurator

    def initialize(searchables, dependency_resolver)
      @searchables = searchables
      @dependency_resolver = dependency_resolver
    end

    def builders_for(resource, action)
      builders = []

      dependent_resources = []

      builders << SearchablesOptionBuilder.new(resource, @searchables)

      if action.params.find{ |p| p.name == "id" }
        dependent_resources += @dependency_resolver.resource_dependencies(resource, :only_required => true, :recursive => true)
      end

      dependent_resources += @dependency_resolver.action_dependencies(action, :only_required => false, :recursive => false)
      dependent_resources += @dependency_resolver.action_dependencies(action, :only_required => true, :recursive => true)

      unique(dependent_resources).each do |dep_resource|
        builders << DependentSearchablesOptionBuilder.new(dep_resource, @searchables)
      end

      builders
    end

    protected

    def unique(resources)
      # ruby 1.8 hack - it does not support passing blocks to Array#uniq
      resources.inject({}) do |h, r|
        h.update(r.name => r)
      end.values
    end

  end

  class ForemanOptionBuilder < HammerCLI::OptionBuilderContainer

    def initialize(searchables)
      @searchables = searchables
    end

    def build(builder_params={})
      expansion_options = builder_params[:expand] || {}

      allowed_resources = expansion_options[:only] || default_dependent_resources
      allowed_resources -= expansion_options[:except] || []
      allowed_resources += expansion_options[:including] || []
      allowed_resources.uniq!

      primary_resource = expansion_options[:primary]

      to_remove = default_dependent_resources - allowed_resources
      to_add = allowed_resources - default_dependent_resources

      builders.reject! do |b|
        b.class <= DependentSearchablesOptionBuilder && to_remove.include?(b.resource.name)
      end
      to_add.each do |resource_name|
        builders << DependentSearchablesOptionBuilder.new(HammerCLIForeman.foreman_resource(resource_name), @searchables)
      end

      if !primary_resource.nil?
        builders.reject! do |b|
          b.class <= SearchablesOptionBuilder
        end
        builders << SearchablesOptionBuilder.new(HammerCLIForeman.foreman_resource(primary_resource), @searchables) if primary_resource != false
      end

      super
    end

    def default_dependent_resources
      dependent_searchable_builders.map(&:resource).map(&:name)
    end

    def dependent_searchable_builders
      self.builders.select{|b| b.class <= DependentSearchablesOptionBuilder }
    end

  end

  class SearchablesOptionBuilder < HammerCLI::AbstractOptionBuilder

    def initialize(resource, searchables)
      @resource = resource
      @searchables = searchables
    end

    attr_reader :resource

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

    def initialize(resource, searchables)
      @resource = resource
      @searchables = searchables
    end

    attr_reader :resource

    def build(builder_params={})
      dependent_options(@resource)
    end

    protected

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

    attr_reader :resource

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
