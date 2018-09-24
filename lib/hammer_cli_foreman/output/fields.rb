require 'hammer_cli'

module Fields

  class Reference < Field
    def initialize(options={})
      super
      initialize_options
    end

    def initialize_options
      @options[:details] ||= []
      @options[:details] = [@options[:details]] unless @options[:details].is_a?(Array)
      @options[:details] = [id_detail] + @options[:details]
      @options[:display_field_key] ||= @options[:name_key] || :name
    end

    protected

    def id_detail
      {
        :label => _('id'),
        :structured_label => _('Id'),
        :key => @options[:id_key] || :id,
        :id => true
      }
    end
  end

  class SingleReference < Reference
    def initialize_options
      key = @options[:key]
      display_field = @options[:display_field] || 'name'

      @options[:id_key] ||= "#{key}_id"
      @options[:display_field_key] ||= "#{key}_#{display_field}"
      super
    end

    def display?(value)
      id_key = @options[:id_key]
      display_key = @options[:display_field_key]

      (value[display_key.to_sym] || value[display_key]) && (value[id_key.to_sym] || value[id_key])
    end
  end

  class Template < Reference
    def initialize_options
      super
      @options[:details] << template_kind_detail
    end

    def template_kind_detail
      {
        :structured_label => _('Kind'),
        :key => :template_kind_name,
      }
    end
  end

end
