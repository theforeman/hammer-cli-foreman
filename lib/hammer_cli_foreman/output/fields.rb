require 'hammer_cli'

module Fields

  class SingleReference < Field

    def display?(value)
      id_key = "#{parameters[:key]}_id"
      name_key = "#{parameters[:key]}_name"

      (value[name_key.to_sym] || value[name_key]) && (value[id_key.to_sym] || value[id_key])
    end
  end

  class Reference < Field
  end

  class Template < Reference

    def initialize(options={})
      options[:details] ||= [:template_kind_name]
      super(options)
    end
  end

end
