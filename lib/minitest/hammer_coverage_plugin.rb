require 'coverage_reporter'
require "json"

module Minitest
  def self.plugin_hammer_coverage_options(opts, options)
    opts.on "-c", "--coverage", "Generate coverage reports for API endpoints" do
      options[:coverage] = true
    end
  end

  def self.plugin_hammer_coverage_init(options)
    if options[:coverage]
      Minitest.reporter.reporters.clear
      Minitest.after_run do
          Minitest::CoverageRunner.new("test/data/#{ FOREMAN_VERSION }/foreman_api.json").run_tests
      end
    end
  end
end
