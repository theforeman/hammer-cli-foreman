module ResourceMocks

  def self.mock_action_call(resource, action, value, params=:default)
    response = ApipieBindings::Example.new('GET', '/', '', 200, JSON.dump(value))
    @mocks ||= {}
    @mocks[[resource, action]] ||= {}
    @mocks[[resource, action]][params] = response
    ApipieBindings::API.any_instance.stubs(:fake_responses).returns(@mocks)
  end

  def self.clear_mocks
    @mocks = {}
    ApipieBindings::API.any_instance.stubs(:fake_responses).returns(@mocks)
  end

  def self.mock_action_calls(*calls)
    calls.each do |(resource, action, value, params)|
      mock_action_call(resource, action, value, (params || :default))
    end
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

  def self.facts_index
    ResourceMocks.mock_action_call(:fact_values, :index, {
      "total"=>5604,
      "subtotal"=>0,
      "page"=>1,
      "per_page"=>20,
      "search"=>"",
      "sort" => {
        "by" => nil,
        "order" => nil
      },
      "results"=>[{
        "some.host.com" => {
          "network_br180"=>"10.32.83.0",
          "mtu_usb0"=>"1500",
          "physicalprocessorcount"=>"1",
          "rubyversion"=>"1.8.7"
        }
      }]
    })
  end

end
