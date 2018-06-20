require 'hammer_cli/output/adapter/abstract'


class TestAdapter < HammerCLI::Output::Adapter::Abstract

  def print_record(fields, record)
    print_collection(fields, [record].flatten(1))
  end


  def print_collection(fields, data)
    @separator = '#'
    puts @separator+fields.collect{|f| f.label.to_s}.join(@separator)+@separator

    data.collect do |d|
      fields_data = fields.collect do |f|
        begin
          data_for_field(f, d).to_s
        rescue HammerCLI::MissingAPIError
          # This is a workaround for current testing, which makes impossible to
          # test http://projects.theforeman.org/issues/20607 feature becouse of
          # simplified adapter.
          nil.to_s
        end
      end.join(@separator)
      puts "#{@separator}#{fields_data}#{@separator}"
    end
  end

end

HammerCLI::Output::Output.register_adapter(:test, TestAdapter)


