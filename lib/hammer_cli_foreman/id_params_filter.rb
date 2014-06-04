module HammerCLIForeman

  class IdParamsFilter

    def for_action(action, options={})
      required = !(options[:only_required] == false)

      params = flatten_params(action.params)
      params = params.reject{ |p| !(p.name.end_with?("_id")) }
      params = params.reject{ |p| !(p.required?) } if required

      params
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

end
