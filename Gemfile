source "https://rubygems.org"

gemspec

# we'll remove this line once hammer_cli gets more stable
# and won't change so often
gem 'hammer_cli', :github => "theforeman/hammer-cli"

group :test do
  gem 'rake'
  gem 'thor'
  gem 'minitest', '4.7.4'
  gem 'minitest-spec-context'
  gem 'simplecov'
  gem 'mocha'
  gem 'ci_reporter'
end

# load local gemfile
local_gemfile = File.join(File.dirname(__FILE__), 'Gemfile.local')
self.instance_eval(Bundler.read_file(local_gemfile)) if File.exist?(local_gemfile)
