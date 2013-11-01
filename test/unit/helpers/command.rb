require File.join(File.dirname(__FILE__), '../test_output_adapter')


module CommandTestHelper

  def with_params(params, &block)
    context "with params "+params.to_s do
      let(:with_params) { params }
      self.instance_eval &block
    end
  end

  def it_should_call_action(action, params)
    it "should call action "+action.to_s do
      arguments ||= respond_to?(:with_params) ? with_params : []
      cmd.resource.resource_class.expects_with(action, params)
      cmd.run(arguments)
    end
  end

  def it_should_fail_with(message, arguments=[])
    it "should fail with " + message.to_s do
      proc { cmd.run(arguments) }.must_raise Clamp::UsageError
    end
  end

  def it_should_accept(message, arguments=[])
    it "should accept " + message.to_s do
      cmd.run(arguments).must_equal HammerCLI::EX_OK
    end
  end

  def it_should_print_column(column_name, arguments=nil)
    it "should print column " + column_name do
      arguments ||= respond_to?(:with_params) ? with_params : []

      cmd.stubs(:context).returns({ :adapter => :test })
      proc { cmd.run(arguments) }.must_output /.*##{column_name}#.*/
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

      cmd.stubs(:context).returns({ :adapter => :test })
      count ||= expected_record_count rescue 0
      out, err = capture_io do
        cmd.run(arguments)
      end

      out.split(/\n/).length.must_equal count+1 # plus 1 for line with column headers
    end
  end

  def it_should_accept_search_params
    it_should_accept "search", ["--search=some_search"]
    it_should_accept "per page", ["--per-page=1"]
    it_should_accept "page", ["--page=2"]
    it_should_accept "order", ["--order=order"]
  end

end
