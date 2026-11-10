require File.join(File.dirname(__FILE__), 'test_helper')
require 'hammer_cli_foreman/host'
require 'hammer_cli_foreman/location'
require 'csv'
require 'json'
require 'yaml'
require 'stringio'

describe 'parameter info output' do
  let(:parameters) do
    [
      { 'id' => 7, 'name' => 'secret', 'value' => '*****', 'hidden_value?' => true,
        'is_property' => false, 'future_key' => "one; \"two\"\nthree" },
      { 'id' => 8, 'name' => 'enabled', 'value' => false, 'extra' => nil }
    ]
  end
  let(:inherited) do
    [
      { 'id' => 9, 'name' => 'role', 'value' => 'web', 'is_property' => true },
      { 'name' => 'region', 'value' => 'east', 'future_key' => 'new' }
    ]
  end
  let(:record) { { 'parameters' => parameters, 'all_parameters' => inherited } }

  def render_info(adapter, data, options = {}, command = HammerCLIForeman::Host::InfoCommand)
    stream = StringIO.new
    context = { :adapter => adapter, :output_file => stream, :fields => ['parameters', 'all parameters'] }.merge(options)
    command.new('', context).print_data(data)
    stream.string
  end

  it 'preserves compact human output for both collections and masked values' do
    output = render_info(:base, record)
    assert_includes output, 'secret => *****'
    assert_includes output, 'enabled => false'
    assert_includes output, 'role => web'
    assert_includes output, 'region => east'
    refute_includes output, 'Hidden value:'
    refute_includes output, 'future_key'
  end

  it 'preserves raw JSON and YAML parameter objects including unknown keys' do
    json = JSON.parse(render_info(:json, record))
    yaml = YAML.safe_load(render_info(:yaml, record))
    [json, yaml].each do |parsed|
      assert_equal parameters, parsed['Parameters']
      assert_equal inherited, parsed['All parameters']
    end
  end

  it 'flattens every returned key for CSV, including previously visible IDs' do
    output = render_info(:csv, record, :csv_separator => ';')
    assert_includes output, '"one; ""two""'
    table = CSV.parse(output, :headers => true, :col_sep => ';')
    assert_equal 1, table.length
    row = table.first
    assert_equal '7', row['Parameters::id::1']
    assert_equal '9', row['All parameters::id::1']
    assert_equal '*****', row['Parameters::value::1']
    assert_equal 'true', row['Parameters::hidden_value?::1']
    assert_equal 'false', row['Parameters::is_property::1']
    assert_equal parameters.first['future_key'], row['Parameters::future_key::1']
    assert_equal 'false', row['Parameters::value::2']
    assert_equal '', row['Parameters::future_key::2']
    assert_nil row['Parameters::extra::2']
    assert_equal 'true', row['All parameters::is_property::1']
    assert_equal 'new', row['All parameters::future_key::2']
  end

  it 'includes IDs when requested and does not mutate the shared definition' do
    row = CSV.parse(render_info(:csv, record, :show_ids => true), :headers => true).first
    assert_equal '7', row['Parameters::id::1']
    assert_equal '9', row['All parameters::id::1']
    assert_equal parameters, JSON.parse(render_info(:json, record))['Parameters']
    assert_equal '7', CSV.parse(render_info(:csv, record), :headers => true).first['Parameters::id::1']
  end

  it 'handles missing collections and empty collections without invented parameter columns' do
    output = render_info(:csv, { 'parameters' => [], 'all_parameters' => [] })
    refute_includes output, 'Parameters::'
    output = render_info(:csv, {})
    refute_includes output, 'Parameters::'
  end

  it 'uses the same behavior in another info command' do
    output = render_info(:base, { 'parameters' => parameters }, {}, HammerCLIForeman::Location::InfoCommand)
    assert_includes output, 'secret => *****'
    row = CSV.parse(render_info(:csv, { 'parameters' => parameters }, {}, HammerCLIForeman::Location::InfoCommand), :headers => true).first
    assert_equal parameters.first['future_key'], row['Parameters::future_key::1']
  end

  it 'preserves unusual CSV keys and rejects ambiguous non-JSON input' do
    data = { 'parameters' => [{ 'name' => 'a', 'value' => 'b', '' => 'empty', 'extra::key' => 'present' }] }
    row = CSV.parse(render_info(:csv, data), :headers => true).first
    assert_equal 'empty', row['Parameters::::1']
    assert_equal 'present', row['Parameters::extra::key::1']
    ambiguous = { 'parameters' => [{ 'name' => 'a', :name => 'b' }] }
    assert_raises(ArgumentError) { render_info(:csv, ambiguous) }
  end

  it 'supports selecting an individual CSV parameter field' do
    row = CSV.parse(render_info(:csv, record, :fields => ['parameters/name']), :headers => true).first
    assert_equal 'secret', row['Parameters::name::1']
    assert_equal 'enabled', row['Parameters::name::2']
    refute_includes row.headers, 'Parameters::value::1'
    refute row.headers.any? { |header| header.start_with?('All parameters::') }
  end
end
