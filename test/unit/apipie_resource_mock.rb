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
    ResourceMocks.mock_action_call(:smart_class_parameters, :index,
      { "results" => [ { 'parameter' => 'config', 'id' => '1'} ] })
  end

  def self.smart_class_parameters_show
    ResourceMocks.mock_action_call(:smart_class_parameters, :show, { 'smart_class_parameter' => { 'override_value_order' => '', 'environments' => [] }})
  end

  def self.smart_variables_index
    ResourceMocks.mock_action_call(:smart_variables, :index,
      { "results" => [ { 'variable' => 'var', 'id' => '1'} ] })
  end

  def self.smart_variables_show
    ResourceMocks.mock_action_call(:smart_variables, :show, { "id" => 1, "override_value_order" => "fqdn" })
  end

  def self.compute_resources_available_images
    ResourceMocks.mock_action_call(:compute_resources, :available_images, [])
  end

  def self.compute_resources_available_networks
    ResourceMocks.mock_action_call(:compute_resources, :available_networks, [])
  end

  def self.organizations_index
    ResourceMocks.mock_action_call(:organizations, :index, {
     "results" => [
        {
                 "label" => "Default_Organization",
                    "id" => 1,
                  "name" => "Default_Organization",
                 "title" => "Default_Organization"
        }
      ]})
  end

  def self.users_show
    ResourceMocks.mock_action_call(:users, :show, {
      "firstname" => "Admin",
      "lastname" => "User",
      "mail" => "root@example.com",
      "admin" => true,
      "auth_source_id" => 1,
      "auth_source_name" => "Internal",
      "timezone" => nil,
      "locale" => nil,
      "last_login_on" => "2016-12-20 17:30:13 UTC",
      "created_at" => "2016-10-24 08:11:24 UTC",
      "updated_at" => "2016-10-24 08:11:38 UTC",
      "id" => 3,
      "login" => "admin",
      "description" => nil,
      "default_location" => nil,
      "locations" => [],
      "default_organization" => {
        "id" => 1,
        "name" => "Default Organization",
        "title" => "Default Organization",
        "description" => nil
      },
      "organizations" => [],
      "effective_admin" => true,
      "cached_usergroups" => [],
      "auth_source_internal" => {
        "id" => 1,
        "type" => "AuthSourceInternal",
        "name" => "Internal"
      },
      "mail_notifications" => [],
      "roles" => [{
        "name" => "Default role",
        "id" => 9,
        "description" => nil
      }],
      "usergroups" => []
    })
  end

  def self.hosts_show
    ResourceMocks.mock_action_call(:hosts, :show, {
      "ip" => "192.168.122.51",
      "ip6" => nil,
      "environment_id" => 1,
      "environment_name" => "production",
      "last_report" => "2016-10-24 12:06:31 UTC",
      "mac" => "52:54:00:ce:b2:b9",
      "realm_id" => nil,
      "realm_name" => nil,
      "sp_mac" => nil,
      "sp_ip" => nil,
      "sp_name" => nil,
      "domain_id" => 1,
      "domain_name" => "tstrachota.usersys.redhat.com",
      "architecture_id" => 1,
      "architecture_name" => "x86_64",
      "operatingsystem_id" => 1,
      "operatingsystem_name" => "CentOS 7.2.1511",
      "build" => false,
      "model_id" => 1,
      "hostgroup_id" => nil,
      "owner_id" => nil,
      "owner_type" => nil,
      "enabled" => true,
      "managed" => false,
      "use_image" => nil,
      "image_file" => "",
      "uuid" => nil,
      "compute_resource_id" => nil,
      "compute_resource_name" => nil,
      "compute_profile_id" => nil,
      "compute_profile_name" => nil,
      "capabilities" => ["build"],
      "provision_method" => "build",
      "certname" => "foreman.example.com",
      "image_id" => nil,
      "image_name" => nil,
      "created_at" => "2016-10-24 08:36:43 UTC",
      "updated_at" => "2016-10-24 12:06:46 UTC",
      "last_compile" => "2016-10-24 12:06:41 UTC",
      "global_status" => 0,
      "global_status_label" => "Warning",
      "organization_id" => nil,
      "organization_name" => nil,
      "location_id" => nil,
      "location_name" => nil,
      "puppet_status" => 0,
      "model_name" => "KVM",
      "configuration_status" => 0,
      "configuration_status_label" => "No reports",
      "name" => "foreman.example.com",
      "id" => 1,
      "puppet_proxy_id" => 1,
      "puppet_proxy_name" => "foreman.example.com",
      "puppet_ca_proxy_id" => 1,
      "puppet_ca_proxy_name" => "foreman.example.com",
      "puppet_proxy" => {
        "name" => "foreman.example.com",
        "id" => 1,
        "url" => "https://foreman.example.com:9090"
      },
      "puppet_ca_proxy" => {
        "name" => "foreman.example.com",
        "id" => 1,
        "url" => "https://foreman.example.com:9090"
      },
      "hostgroup_name" => nil,
      "hostgroup_title" => nil,
      "parameters" => [],
      "all_parameters" => [],
      "interfaces" => [{
        "id" => 1,
        "name" => "foreman.example.com",
        "ip" => "192.168.122.51",
        "mac" => "52:54:00:ce:b2:b9",
        "identifier" => "eth0",
        "primary" => true,
        "provision" => true,
        "type" => "interface"
      },
      {
        "id" => 2,
        "name" => nil,
        "ip" => "10.34.130.105",
        "mac" => "52:54:00:f5:1b:57",
        "identifier" => "eth1",
        "primary" => false,
        "provision" => false,
        "type" => "interface"
      }],
      "puppetclasses" => [],
      "config_groups" => [],
      "all_puppetclasses" => []
    })
  end


  def self.organizations_show
    ResourceMocks.mock_action_calls(
      [:organizations, :index, [{ "id" => 2, "name" => "ACME" }]],
      [:organizations, :show, { "id" => 2, "name" => "ACME" }]
      )
  end

  def self.locations_index
    ResourceMocks.mock_action_call(:locations, :index, {
      "results" => [
        {
              "ancestry" => nil,
            "created_at" => "2014-07-17T17:21:49+02:00",
            "updated_at" => "2015-06-17T13:18:10+02:00",
                    "id" => 2,
                  "name" => "Default_Location",
                 "title" => "Default_Location"
        }
      ]})
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
      [:operatingsystems, :index, []],
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

  def self.auth_source_ldap_index
    ResourceMocks.mock_action_call(:auth_source_ldaps, :index, {
      "results" => [{
        "name" => "my LDAP",
        "id" => 1,
        "tls" => false,
        "port" => 389,
        "server_type" => "POSIX"
      }]
    })
  end

  def self.compute_resource_show
    cr = {
      "name" => "My compute resource",
      "id" => 42,
      "provider" => "Libvirt"
    }
    ResourceMocks.mock_action_calls(
      [:compute_resources, :index, [ "results" => cr ]],
      [:compute_resources, :show, cr]
    )
  end

  def self.common_parameter_show
    ResourceMocks.mock_action_call(:common_parameters, :show, {
      "name" => "my param",
      "value" => "random value"
    })
  end

  def self.config_groups_index
    ResourceMocks.mock_action_call(:config_groups, :index, [{
      :id => 15,
      :name => "test config group",
      :puppetclasses => [ { :name => "My puppetclass" } ]
    }])
  end
end
