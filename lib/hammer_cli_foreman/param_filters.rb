module HammerCLIForeman

  class AbstractParamsFilter

    def for_action(action)
      filter(action.params)
    end

    def filter(params)
      []
    end

  end

  class ParamsFlattener < AbstractParamsFilter

    def filter(params)
      flatten_params(params)
    end

    private

    def flatten_params(params)
      result = params
      params.each do |p|
        result += flatten_params(p.params)
      end
      result
    end

  end

  class IdParamsFilter < AbstractParamsFilter

    def initialize(options={})
      @required = !(options[:only_required] == false)
    end

    def filter(params)
      params = ParamsFlattener.new.filter(params)
      params = params.select{ |p| p.name.end_with?("_id") }
      params = params.select{ |p| p.required? } if @required
      params
    end

  end


  class IdArrayParamsFilter < AbstractParamsFilter

    def initialize(options={})
      @required = !(options[:only_required] == false)
    end

    def filter(params)
      params = ParamsFlattener.new.filter(params)
      params = params.select{ |p| p.name.end_with?("_ids") }
      params = params.select{ |p| p.required? } if @required
      params
    end

  end


  class ParamsNameFilter < AbstractParamsFilter

    def initialize(name)
      @name = name
    end

    def filter(params)
      ParamsFlattener.new.filter(params).select{ |p| p.name == @name }
    end

  end

end
