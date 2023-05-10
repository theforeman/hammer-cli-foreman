require File.join(File.dirname(__FILE__), '../test_output_adapter')

class IdResolverTestProxy

  attr_reader :api

  def initialize(original_resolver)
    @original_resolver = original_resolver
  end

  def self.for_resolver(original_resolver)
    resolver = Class.new(IdResolverTestProxy) do |cls|
      original_resolver.api.resources.each do |resource|
        method_name = "#{resource.singular_name}_id"
        cls.define_method(method_name) do |options|
          value = options[HammerCLI.option_accessor_name("id")]
          value ||= HammerCLI::NilValue if searchables(resource).any? do |s|
            options[HammerCLI.option_accessor_name(s.name)] == HammerCLI::NilValue
          end
          value ||= 1 if searchables(resource).any? do |s|
            !options[HammerCLI.option_accessor_name(s.name)].nil?
          end
          value
        end

        method_name = "#{resource.singular_name}_ids"
        cls.define_method(method_name) do |options|
          options["option_#{resource.singular_name}_ids"].nil? ? nil : [1]
        end
      end
    end

    resolver.new(original_resolver)
  end

  def scoped_options(scope, options, mode = nil)
    @original_resolver.scoped_options(scope, options, mode)
  end

  def searchables(resource)
    @original_resolver.searchables(resource)
  end
end


module CommandTestHelper

  def self.included(base)
    base.extend(ClassMethods)

    base.before :each do
      resolver = cmd.resolver
      cmd.stubs(:resolver).returns(IdResolverTestProxy.for_resolver(resolver))
    end
  end

  def count_records(data)
    HammerCLIForeman.collection_to_common_format(data['results']).count
  end

  module ClassMethods

    def with_params(params, &block)
      context "with params "+params.to_s do
        let(:with_params) { params }
        self.instance_eval(&block)
      end
    end

    def it_should_call_action(action, params, headers={})
      it "should call action "+action.to_s do
        arguments ||= respond_to?(:with_params) ? with_params : []
        ApipieBindings::API.any_instance.expects(:call).with() do |r,a,p,h,o|
          (r == cmd.resource.name && a == action && p == params && h == headers)
        end
        cmd.run(arguments)
      end
    end

    def it_should_call_action_and_test_params(action, &block)
      it "should call action "+action.to_s do
        arguments ||= respond_to?(:with_params) ? with_params : []
        ApipieBindings::API.any_instance.expects(:call).with() do |r,a,p,h,o|
          (r == cmd.resource.name && a == action && yield(p))
        end
        cmd.run(arguments)
      end
    end

    def it_should_fail_with(message, arguments=[])
      it "should fail with " + message.to_s do
        _(cmd.run(arguments)).must_equal HammerCLI::EX_USAGE
      end
    end

    def it_should_accept(message, arguments=[])
      it "should accept " + message.to_s do
        _out, _err = capture_io do
          _(cmd.run(arguments)).must_equal HammerCLI::EX_OK
        end
      end
    end

    def it_should_output(message, adapter=:base)
      it "should output '" + message.to_s + "'" do
        arguments ||= respond_to?(:with_params) ? with_params : []
        cmd.stubs(:context).returns(ctx.update(:adapter => adapter))
        out, _ = capture_io do
          cmd.run(arguments)
        end
        _(out).must_include message
      end
    end

    def it_should_print_column(column_name, arguments=nil)
      it "should print column " + column_name do
        arguments ||= respond_to?(:with_params) ? with_params : []

        cmd.stubs(:context).returns(ctx.update(:adapter => :test))
        out, _ = capture_io do
          cmd.run(arguments)
        end

        _(out.split("\n")[0]).must_match(/.*##{column_name}#.*/)
      end
    end

    def it_should_print_columns(column_names, arguments=nil)
      column_names.each do |name|
        it_should_print_column name, arguments
      end
    end

    def it_should_print_n_records(count=nil, arguments=nil)
      it "should print correct count of records" do
        arguments ||= respond_to?(:with_params) ? with_params : []

        cmd.stubs(:context).returns(ctx.update(:adapter => :test))
        count ||= expected_record_count rescue 0
        out, _ = capture_io do
          cmd.run(arguments)
        end
        _(out.split(/\n/).length).must_equal count+1 # plus 1 for line with column headers
      end
    end

    def it_should_accept_search_params
      it_should_accept "search", ["--search=some_search"]
      it_should_accept "per page", ["--per-page=1"]
      it_should_accept "page", ["--page=2"]
      it_should_accept "order", ["--order=order"]
    end
  end

end
