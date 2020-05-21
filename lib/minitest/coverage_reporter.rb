require "json"

module Minitest
  class CoverageRunner

    RESOURCE_BLACK_LIST = ['tasks','home','config_groups','statistics','table_preferences','autosign','puppet_hosts']
    attr_reader :raw_data, :api_endpoints, :covered_resources, :uncovered_resources, :partially_covered_resources
    def initialize(file_path)
      @raw_data = JSON.load(File.open(file_path))
      @api_endpoints = {}
      @covered_resources = []
      @uncovered_resources = []
      @partially_covered_resources = {}
    end

    def filtered_endpoints(covered)
      api_endpoints.select { |_k, v| v == covered }.keys
    end

    def get_endpoints_by_resource(endpoints)
      endpoints_by_resource = {}
      endpoints.each do |url|
        resource,action = url.split("/")
        endpoints_by_resource[resource] ||= []
        endpoints_by_resource[resource] << action
      end
      endpoints_by_resource
    end

    def uncovered_endpoints_by_resource
      get_endpoints_by_resource(filtered_endpoints(false))
    end

    def covered_endpoints_by_resource
      get_endpoints_by_resource(filtered_endpoints(true))
    end

    def get_coverage
      get_endpoints_by_resource(api_endpoints.keys).each do |resource, actions|
        if covered_endpoints_by_resource[resource] == actions
          @covered_resources << resource
        elsif uncovered_endpoints_by_resource[resource] == actions
          @uncovered_resources << resource
        else
          @partially_covered_resources[resource] = uncovered_endpoints_by_resource[resource]
        end
      end
    end

    def endpoints_percentage(endpoints)
      "#{(endpoints.count / api_endpoints.count.to_f * 100 ).to_i}%"
    end

    def uncovered_endpoints_percentage
      endpoints_percentage(filtered_endpoints(false))
    end

    def covered_endpoints_percentage
      endpoints_percentage(filtered_endpoints(true))
    end

    def run_tests
      raw_data["docs"]["resources"].each do |resource|
        resource[1]["methods"].each do | method |
          @api_endpoints[method["doc_url"].delete_prefix!("../apidoc/v2/")] = false
        end unless RESOURCE_BLACK_LIST.include? resource[0]
      end
      HammerCLIForeman::Testing::APIExpectations.api_calls.each do |api_call|
        resource, action = api_call
          url = "#{resource}/#{action}"
          @api_endpoints[url] =  true
      end
      get_coverage
      output_coverage
    end

    def color(str, code)
      puts "\e[#{code}m#{str}\e[0m"
    end

    def output_coverage
      covered_resources
      color("COVERED RESOURCES" , 32)
      puts covered_resources
      color("NOT COVERED AT ALL", 31)
      puts uncovered_resources
      color("PARTIALLY COVERED RESOURCES", 33)
      partially_covered_resources.each do |resource, endpoints|
        puts "#{resource}: #{endpoints.join(' ')}"
      end
      color("covered endpoints #{covered_endpoints_percentage} uncovered endpoints #{uncovered_endpoints_percentage}", 35)
    end
  end
end