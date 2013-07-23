class ApipieResourceMock

  def initialize resource
    @resource = resource
    @resource.doc["methods"].each do |method|
      self.stubs(method["name"]).returns(stub_return_value(method))
    end
  end

  def doc
    @resource.doc
  end

  def new attrs
    return self
  end

  private

  def stub_return_value method
    return [nil, nil] if method["examples"].empty?

    #parse actual json from the example string
    #examples are in format:
    # METHOD /api/some/route
    # <input params in json, multiline>
    # RETURN_CODE
    # <output in json, multiline>
    parse_re = /.*(\n\d+\n)(.*)/m
    json_string = method["examples"][0][parse_re, 2]

    [JSON.parse(json_string), nil]
  end

end


class ApipieDisabledResourceMock

  def initialize resource
    @resource = resource
    @resource.doc["methods"].each do |method|
      self.stubs(method["name"]).raises(RestClient::ResourceNotFound)
    end
  end

  def doc
    @resource.doc
  end

  def new attrs
    return self
  end

end
