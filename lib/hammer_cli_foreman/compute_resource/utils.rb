module HammerCLIForeman
  module ComputeResources
    def self.get_image_uuid(compute_resource_id, image_id)
      HammerCLIForeman.record_to_common_format(
        HammerCLIForeman.foreman_resource(:images).call(
          :show, 'compute_resource_id' => compute_resource_id, 'id' => image_id
        )['uuid']
      )
    end

    def self.get_hostgroup_compute_resource_id(hostgroup_id)
      hostgroup = HammerCLIForeman.record_to_common_format(
          HammerCLIForeman.foreman_resource(:hostgroups).call(:show, 'id' => hostgroup_id)
      )
      compute_resource_id = hostgroup['compute_resource_id']
      if !hostgroup['compute_resource_name'].to_s.strip.empty? && compute_resource_id.nil?
        compute_resource= HammerCLIForeman.record_to_common_format(
          HammerCLIForeman.foreman_resource(:compute_resources).call(
              :index, :search => "name = \"#{hostgroup['compute_resource_name']}\""
          )
        )
        compute_resource_id = compute_resource['results'][0]['id'] if compute_resource['results'][0]
      end
      compute_resource_id
    end

    def self.get_host_compute_resource_id(host_id)
      HammerCLIForeman.record_to_common_format(
        HammerCLIForeman.foreman_resource(:hosts).call(
          :show, 'id' => host_id
        )['compute_resource_id']
      )
    end

    def self.resource_provider(compute_resource_id)
      HammerCLIForeman.record_to_common_format(
        HammerCLIForeman.foreman_resource(:compute_resources).call(
          :show, 'id' => compute_resource_id
        )
      )['provider'].downcase
    end
  end
end
