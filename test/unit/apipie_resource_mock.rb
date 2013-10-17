class ApipieResourceMock

  def initialize(resource)
    @return_values = {}
    @resource = resource
    @resource.doc["methods"].each do |method|
      stub_method(method)
    end
  end

  def doc
    @resource.doc
  end

  def new(attrs)
    return self
  end

  def expects_with(method_name, params)
    self.expects(method_name).with(params).returns(return_value_for(method_name))
  end

  private

  def return_value_for(method_name)
    @return_values[method_name.to_s]
  end

  def stub_method(method)
    value = get_return_value(method)
    self.stubs(method["name"]).returns(value)
    @return_values[method["name"].to_s] = value
  end

  def get_return_value(method)
    return [nil, nil] if method["examples"].empty?

    #parse actual json from the example string
    #examples are in format:
    # METHOD /api/some/route
    # <input params in json, multiline>
    # RETURN_CODE
    # <output in json, multiline>
    parse_re = /.*(\n\d+\n)(.*)/m
    json_string = method["examples"][0][parse_re, 2]
    response = JSON.parse(json_string) rescue json_string

    [response, nil]
  end

end


class ApipieDisabledResourceMock

  def initialize(resource)
    @resource = resource
    @resource.doc["methods"].each do |method|
      self.stubs(method["name"]).raises(RestClient::ResourceNotFound)
    end
  end

  def doc
    @resource.doc
  end

  def new(attrs)
    return self
  end

end

def mock_resource_method(method, response)
  resource_mock = ApipieResourceMock.new(cmd.class.resource.resource_class)
  resource_mock.stubs(method).returns(response)
  cmd.class.resource resource_mock
end
