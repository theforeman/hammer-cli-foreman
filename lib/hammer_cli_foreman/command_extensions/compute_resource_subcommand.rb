module HammerCLIForeman
  module CommandExtensions
    class ComputeResourceSubcommand < HammerCLI::CommandExtensions
      option '--cluster-id', 'ID', _('Cluster ID'),
             deprecated: _('Use --cluster-name instead')
      option '--cluster-name', 'NAME', _('Cluster name or path to search by'),
             attribute_name: :option_cluster_id

      request_params do |params|
        params['cluster_id'] = params['cluster_id'].gsub('/', '%2F') if params['cluster_id']
      end
    end
  end
end
