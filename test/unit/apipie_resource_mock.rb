module ResourceMocks

  def self.mock_action_call(resource, action, value, params=:default)
    response = ApipieBindings::Example.new('GET', '/', '', 200, JSON.dump(value))
    ApipieBindings::API.any_instance.stubs(:fake_responses).returns({ [resource, action] => { params => response } })
  end

  def self.mock_action_calls(*calls)
    responses = calls.inject({}) do |resp, (resource, action, ret_val, par)|
      params = par || :default
      response = ApipieBindings::Example.new('GET', '/', '', 200, JSON.dump(ret_val))
      if resp.has_key?([resource, action])
        resp[[resource, action]][params] = response
      else
        resp[[resource, action]] = { params => response }
      end
      resp
    end
    ApipieBindings::API.any_instance.stubs(:fake_responses).returns(responses)
  end

  def self.smart_class_parameters_index
    ResourceMocks.mock_action_call(:smart_class_parameters, :index, [ { 'parameter' => 'config', 'id' => '1'} ])
  end

  def self.smart_class_parameters_show
    ResourceMocks.mock_action_call(:smart_class_parameters, :show, { 'smart_class_parameter' => { 'override_value_order' => '', 'environments' => [] }})
  end


  def self.compute_resources_available_images
    ResourceMocks.mock_action_call(:compute_resources, :available_images, [])
  end


  def self.organizations_index
    ResourceMocks.mock_action_call(:organizations, :index, [ { } ])
  end

  def self.organizations_show
    ResourceMocks.mock_action_calls(
      [:organizations, :index, [{ "id" => 2, "name" => "ACME" }]],
      [:organizations, :show, { "id" => 2, "name" => "ACME" }]
      )
  end

  def self.locations_index
    ResourceMocks.mock_action_call(:locations, :index, [ { } ])
  end

  def self.locations_show
    ResourceMocks.mock_action_calls(
      [:locations, :index, [{ "id" => 2, "name" => "Rack" }]],
      [:locations, :show, { "id" => 2, "name" => "Rack" }]
      )
  end

  def self.operatingsystems
    ResourceMocks.mock_action_calls(
      [:parameters, :index, []],
      [:operatingsystems, :index, [ {} ]],
      [:operatingsystems, :show, {}]
      )
  end

  def self.parameters_index
    ResourceMocks.mock_action_call(:parameters, :index, [])
  end

end
