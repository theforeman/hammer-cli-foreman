# Data for tests

## How to include API tests for new Foreman release

 1. on the **foreman instance** run the tests with recording of examples turned on

    ```bash
    $ APIPIE_RECORD=examples bundle exec rake test:functionals
    ```
 1. on the **Foreman instance** generate API documentation cache. It will land in `/usr/share/foreman/public/apipie-cache/apidoc/v2.en.json`

    ```bash
    $ FOREMAN_APIPIE_LANGS=en foreman-rake apipie:cache
    ```
 1. when running from **git**, run a similar command and it will land in `$FOREMAN_CHECKOUT/public/apipie-cache/apidoc/v2.en.json`

    ```bash
    $ FOREMAN_APIPIE_LANGS=en bundle exec rake apipie:cache
    ```
 1. in **hammer-cli-foreman** in `test/data/` Create directory with name matching the Foreman version in `test/data/` (e.g. `test/data/1.10`)
 1. copy the API cache from the Foreman instance into the newly created directory and name it as `foreman_api.json`
 1. update the following line in `test/test_helper.rb` to match the new default Foreman version

    ```ruby
    FOREMAN_VERSION = Gem::Version.new(ENV['TEST_API_VERSION'] || '1.10')
    ```
 1. make sure the tests are green
