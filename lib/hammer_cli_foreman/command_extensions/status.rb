module HammerCLIForeman
  module CommandExtensions
    class Status < HammerCLI::CommandExtensions
      before_print do |data|
        return if data['results'].nil?

        normalize_plugins(data['results']['foreman']['plugins']) if data['results']['foreman']['plugins'].any?(String)
        data['results']['foreman']['smart_proxies'].each do |proxy|
          proxy['features'] = normalize_features(proxy['features'])
          proxy['failed_features'] = normalize_failed_features(proxy['failed_features'])
        end
      end

      def self.normalize_plugins(plugins)
        plugins.map! do |plugin|
          name, version = plugin.split(': ', 2)[1].split(', ', 3)[0..1]
          { name: name, version: version }
        end
      end

      def self.normalize_features(features)
        active_features = []
        features.each_pair do |name, version|
          active_features << {
            name: name,
            version: version
          }
        end
        active_features
      end

      def self.normalize_failed_features(features)
        failed_features = []
        features.each_pair do |name, error|
          failed_features << {
            name: name,
            error: error
          }
        end
        failed_features
      end
    end
  end
end
