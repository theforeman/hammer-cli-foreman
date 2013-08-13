require File.join(File.dirname(__FILE__), '../test_output_adapter')

module CommandTestHelper

  def it_should_fail_with message, arguments=[]
    it "should fail with " + message.to_s do
      cmd.output.adapter = HammerCLI::Output::Adapter::Silent.new
      proc { cmd.run(arguments) }.must_raise Clamp::UsageError
    end
  end

  def it_should_accept message, arguments=[]
    it "should accept " + message.to_s do
      cmd.output.adapter = HammerCLI::Output::Adapter::Silent.new
      cmd.run(arguments).must_equal 0
    end
  end

  def it_should_print_column column_name, arguments=nil
    it "should print column " + column_name do
      arguments ||= respond_to?(:with_params) ? with_params : []

      cmd.output.adapter = TestAdapter.new
      proc { cmd.run(arguments) }.must_output /.*##{column_name}#.*/
    end
  end

  def it_should_print_columns column_names, arguments=nil
    column_names.each do |name|
      it_should_print_column name, arguments
    end
  end

  def it_should_print_n_records count=nil, arguments=nil
    it "should print " + count.to_s + " records" do
      arguments ||= respond_to?(:with_params) ? with_params : []

      cmd.output.adapter = TestAdapter.new
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
