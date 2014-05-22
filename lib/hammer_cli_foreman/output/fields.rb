require 'hammer_cli'

module Fields

  class SingleReference < Field
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
