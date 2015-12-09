module CommandAssertions

  class CommandRunResult
    def initialize(out="", err="", exit_code=0)
      @out = out
      @err = err
      @exit_code = exit_code
    end
    attr_accessor :out, :err, :exit_code
  end

  def run_cmd(options, context={}, cmd_class=HammerCLI::MainCommand)
    result = CommandRunResult.new
    result.out, result.err = capture_io do
      result.exit_code = cmd_class.run('hammer', options, context)
    end
    result
  end

  def exit_code_map
    return @exit_code_map unless @exit_code_map.nil?

    hammer_exit_codes = HammerCLI.constants.select{|c| c.to_s.start_with?('EX_')}
    @exit_code_map = hammer_exit_codes.inject({}) do |code_map, code|
      code_map.update(HammerCLI.const_get(code) => code)
    end
  end

  def assert_exit_code_equal(expected_code, actual_code)
    expected_info = "#{exit_code_map[expected_code]} (#{expected_code})"
    actual_info = "#{exit_code_map[actual_code]} (#{actual_code})"

    msg = "The exit code was expected to be #{expected_info}, but it was #{actual_info}"
    assert(expected_code == actual_code, msg)
  end

  def assert_cmd(expected_result, actual_result)
    assert_equal expected_result.err, actual_result.err
    assert_equal expected_result.out, actual_result.out
    assert_exit_code_equal expected_result.exit_code, actual_result.exit_code
  end

  def usage_error(command, heading, message)
    command = (['hammer'] + command).join(' ')
    ["#{heading}:",
     "  Error: #{message}",
     "  ",
     "  See: '#{command} --help'",
     ""].join("\n")
  end

  def common_error(command, heading, message)
    command = (['hammer'] + command).join(' ')
    ["#{heading}:",
     "  Error: #{message}",
     ""].join("\n")
  end

  def usage_error_result(command, heading, message)
    expected_result = CommandRunResult.new
    expected_result.err = usage_error(command, heading, message)
    expected_result.exit_code = HammerCLI::EX_USAGE
    expected_result
  end

  def common_error_result(command, heading, message)
    expected_result = CommandRunResult.new
    expected_result.err = common_error(command, heading, message)
    expected_result.exit_code = HammerCLI::EX_SOFTWARE
    expected_result
  end

  def success_result(message)
    CommandRunResult.new(message)
  end
end
