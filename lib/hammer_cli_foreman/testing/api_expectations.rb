module HammerCLIForeman
  module Testing
    module APIExpectations
      class APICallMatcher < Mocha::ParameterMatchers::Base
        attr_accessor :expected_params, :expected_resource, :expected_action, :block

        def initialize(resource=nil, action=nil, &block)
          @expected_resource = resource
          @expected_action = action
          @block = block if block_given?
          @expected_params = {}
        end

        def matches?(actual_parameters)
          action, params, headers, options = actual_parameters.shift(4)
          action_name = action.name.to_s
          resource_name = action.resource.to_s

          result = true
          result &&= (resource_name == @expected_resource.to_s) unless @expected_resource.nil?
          result &&= (action_name == @expected_action.to_s) unless @expected_action.nil?
          result &&= @block.call(params) if @block
          result &&= assert_params(params)
          result
        end

        def mocha_inspect
          res = @expected_resource.nil? ? 'any_resource' : ":#{@expected_resource}"
          act = @expected_action.nil? ? 'any_action' : ":#{@expected_action}"
          blk = @block ? '&block' : '*any_argument'
          "#{res}, #{act}, #{blk}"
        end

        protected
        def assert_params(params)
          stringify_keys(params) == deep_merge_hash(stringify_keys(params), stringify_keys(@expected_params))
        end

        def deep_merge_hash(h, other_h)
          h = h.clone
          h.merge!(other_h) do |key, old_val, new_val|
            if old_val.is_a?(Hash) && new_val.is_a?(Hash)
              deep_merge_hash(old_val, new_val)
            else
              new_val
            end
          end
        end

        def stringify_keys(hash)
          hash.inject({}) do |stringified, (key, value)|
            if value.is_a?(Hash)
              value = stringify_keys(value)
            end
            stringified.update(key.to_s => value)
          end
        end
      end

      module ExpectationExtensions
        def method_signature
          signature = "#{@note}\n  #{super}"
          if @api_call_matcher && !@api_call_matcher.expected_params.empty?
            signature += "\n  expected params to include: " + params_signature(@api_call_matcher.expected_params)
          end
          if @api_call_matcher && !@api_call_matcher.block.nil?
            signature += "\n  expected params to match block at: " + block_signature(@api_call_matcher.block)
          end
          signature
        end

        def params_signature(hash)
          JSON.pretty_generate(hash).split("\n").join("\n  ")
        end

        def block_signature(block)
          block.source_location.join(':')
        end

        def set_note(note)
          @note = note
        end

        def with_params(expected_params = {}, &block)
          api_call_matcher.expected_params = expected_params
          api_call_matcher.block = block if block_given?
          self.with(api_call_matcher)
          self
        end

        def with_action(resource, action)
          api_call_matcher.expected_resource = resource
          api_call_matcher.expected_action = action
          self.with(api_call_matcher)
          self
        end

        def api_call_matcher
          @api_call_matcher ||= APICallMatcher.new
        end
      end

      class APIExpectationsDecorator < SimpleDelegator
        def initialize(api_instance = ApipieBindings::API.any_instance)
          @api_instance = api_instance
          super
        end

        def expects_call(resource=nil, action=nil, note=nil, &block)
          ex = @api_instance.expects(:call_action)
          ex.extend(ExpectationExtensions)
          ex.with_action(resource, action).with_params(&block)
          ex.set_note(note)
          ex
        end

        def expects_no_call
          @api_instance.expects(:call_action).never
        end

        def expects_search(resource=nil, search_options={}, note=nil)
          note ||= "Find #{resource}"

          if search_options.is_a?(Hash)
            search_query = search_options.map{|k, v| "#{k} = \"#{v}\"" }.join(" or ")
          else
            search_query = search_options
          end

          expects_call(resource, :index, note).with_params(:search => search_query)
        end
      end

      class TestAuthenticator < ApipieBindings::Authenticators::BasicAuth
        def user(ask=nil)
          @user
        end

        def password(ask=nil)
          @password
        end
      end

      class FakeApiConnection < HammerCLI::Apipie::ApiConnection
        attr_reader :authenticator

        def initialize(params, options = {})
          @authenticator = params[:authenticator]
          super
        end
      end

      def api_connection(options={}, version = '1.15')
        FakeApiConnection.new({
          :uri => 'https://test.org',
          :apidoc_cache_dir => "test/data/#{version}",
          :apidoc_cache_name => 'foreman_api',
          :authenticator => TestAuthenticator.new('admin', 'changeme'),
          :dry_run => true
        }.merge(options))
      end

      def api_expects(resource=nil, action=nil, note=nil, &block)
        APIExpectationsDecorator.new.expects_call(resource, action, note, &block)
      end

      def api_expects_no_call
        APIExpectationsDecorator.new.expects_no_call
      end

      def api_expects_search(resource=nil, search_options={}, note=nil)
        APIExpectationsDecorator.new.expects_search(resource, search_options, note)
      end

      def index_response(items, options={})
        cnt = items.length
        {
          "total" => options.fetch(:total, cnt),
          "subtotal" => options.fetch(:subtotal, cnt),
          "page" => options.fetch(:page, 1),
          "per_page" => options.fetch(:per_page, cnt),
          "search" => "",
          "sort" => {
            "by" => nil,
            "order" => nil
          },
          "results" => items
        }
      end
    end
  end
end
