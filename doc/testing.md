# Testing hammer commands

Commands from `hammer-cli-foreman` are tested by two types of tests:
- *unit tests* - They're placed in `test/unit` and test only basic functionality of the commands like accepted options and field labels printed to stdout. Unit tests for commands are no longer extended.
- *functional tests* - They're placed in `test/functional` and aim to test commands in broader context. Functional tests require mocking the api calls and should also test output based on data returned from the api. This is preferable way of testing the commands.


## Running the tests

```bash
bundle install
bundle exec rake test
```

Generated coverage reports are stored in ./coverage directory.

There is support for testing against API documentation generated from different versions of Foreman.
The required version of Foreman can be set in env variable `TEST_API_VERSION`. Make sure the requested data are in `test/unit/data/<version>/`.
```bash
$ TEST_API_VERSION=1.13 bundle exec rake test
```

## Testing API expectations

`hammer-cli-foreman` comes with a set of helpers and extensions to [Mocha](https://github.com/freerange/mocha) library for easier testing and better error detection.

The extensions are included in `test/test_helper.rb` by default. It's also possible to include it elswhere when needed:
```ruby
require 'hammer_cli_foreman/testing/api_expectations'
include HammerCLIForeman::Testing::APIExpectations
```

### Available helper functions

**`api_expects`**`(resource=nil, action=nil, note=nil, &block)`
* `resource` Symbol with plural name of the resource.
* `action` Symbol with action name.
* `note` String with description of the expected call to make its identification easier when the expectation fails.
* `&block` Optional block for testing parameters.

 `api_expects` is often used together with `with_params` that set expectation on parameters that need to be included in the call:
```ruby
describe 'hostgroup create' do
  it 'passes architecture id' do
    api_expects(:hostgroups, :create, 'Create hostgroup with architecture_id').with_params('hostgroup' => {
      'name' => 'hg1',
      'architecture_id' => 1
    })

    run_cmd(%w(hostgroup create --name hg1 --architecture-id 1))
  end
end
```

The expectation failure is reported with description of the call and expected parameters to make searching for mistakes easier:
```
unexpected invocation: #<AnyInstance:ApipieBindings::API>.call_action(<Action hostgroups:create>, {'hostgroup' => {'name' => 'hg1', 'architecture_id' => 2}}, {}, {:fake_response => nil})
unsatisfied expectations:
- expected exactly once, not yet invoked: Create hostgroup with architecture_id
  #<AnyInstance:ApipieBindings::API>.call_action(:hostgroups, :create, *any_argument)
  expected params to include: {
    "hostgroup": {
      "name": "hg1",
      "architecture_id": 1
    }
  }
```

Alternatively parameters can be tested in a block:
```ruby
describe 'hostgroup create' do
  it 'passes architecture id' do
    api_expects(:hostgroups, :create, 'Create hostgroup with architecture_id') do |p|
      p['hostgroup']['architecture_id'] == 1 && p['hostgroup']['name'] == 'hg1'
    end

    run_cmd(%w(hostgroup create --name hg1 --architecture-id 1))
  end
end
```

This approach gives more freedom in what is tested and how but can't report what parameters were expected in case of failure.

**`api_expects_no_call`**

Makes sure no API call is performed.

Example:
```ruby
describe 'hostgroup create' do
  it "doesn't perform any api request when name is missing" do
    api_expects_no_call
    run_cmd(%w(hostgroup create))
  end
end
```

**`api_expects_search`**`(resource=nil, search_options={}, note=nil)`
* `resource` Symbol with plural name of the resource.
* `search_options` Either hash with options to search by (eg. `:name => 'x86_64'`) or a string with the search query.
* `note` String with description of the expected call to make its identification easier when the expectation fails.

Helper that sets expectation on searching for a resource when hammer translates from name of the resource to its id. It's often used together with `returns` that mocks result of the search query.

Example:
```ruby
describe 'hostgroup create' do
  let(:arch) {{'id' => 1, 'name' => 'arch1'}}

  it 'resolves architecture name' do
    api_expects_search(:architectures, { :name => 'arch1' }).returns(index_response([arch]))
    run_cmd(%w(hostgroup create --name hg1 --architecture arch1))
  end
end
```

**`api_connection`**`(options={}, version = '1.15')`
* `options` Hash with options for the api connection.
* `version` Version of the Foreman apidoc. Available exported versions are located in subdirectories of `test/data/`.

The function returns instance of `FakeApiConnection` that makes `#authenticator` public and allows setting expectations on it. Useful for injection of api instances into tested objects.

**`APIExpectationsDecorator`**

Decorator class that adds helpers for setting expectations on the wrapped api instance.
Provides methods `expects_call`, `expects_no_call` and `expects_search` that behave similarly to the helpers described above.

Example usage:
```ruby
connection = api_connection
api = APIExpectationsDecorator.new(connection.api)
api.expects_search(:users, 'login=admin')
```
## Checking the coverage against the API
You can check how many API endpoints are covered by Hammer, this test runs all hammer tests,
and check which API actions run, therefore there could be two reasons for an endpoint to not be covered:
1. there is no test for this action
2. there is no hammer command for the API endpoint.
### running the coverage test
```bash

rake test TESTOPTS="-c"

TEST_API_VERSION=2.0 rake test TESTOPTS="-c"

```
