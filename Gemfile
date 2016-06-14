source "https://rubygems.org"

group :production do
  gemspec
end

gem 'gettext', '>= 3.1.3', '< 4.0.0'

group :test do
  gem 'rake', '~> 10.1.0'
  gem 'thor'
  gem 'minitest', '4.7.4'
  gem 'minitest-spec-context'
  gem 'simplecov'
  gem 'mocha'
  gem 'ci_reporter', '>= 1.6.3', "< 2.0.0", :require => false
end

group :test, :development do
  gem 'hammer_cli', git: 'https://github.com/theforeman/hammer-cli.git'
  gem 'apipie-bindings', '>=0.0.16'
end

# load local gemfile
['Gemfile.local.rb', 'Gemfile.local'].map do |file_name|
  local_gemfile = File.join(File.dirname(__FILE__), file_name)
  self.instance_eval(Bundler.read_file(local_gemfile)) if File.exist?(local_gemfile)
end
