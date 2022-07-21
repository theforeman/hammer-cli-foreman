require File.join(File.dirname(__FILE__), 'test_helper')

describe 'table_preference' do
  let(:base_cmd) { ['user', 'table-preference'] }
  let(:user) do
    {
      :id => 1,
      :name => 'admin'
    }
  end
  let(:table_preference) do
    {
      :id => 1,
      :user_id => user[:id],
      :name => 'Table Preference',
      :columns => ['A', 'B', 'C']
    }
  end

  describe 'list' do
    let(:cmd) { base_cmd << 'list' }

    it 'lists table preferences for a given user' do
      params = ['--user-id', user[:id]]
      api_expects(:table_preferences, :index, params)
        .returns(index_response([table_preference]))

      expected_result = success_result(/#{table_preference[:name]}/)

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'create' do
    let(:cmd) { base_cmd << 'create' }

    it 'creates a table preference for a given table' do
      params = ['--user-id', user[:id],
                '--name', table_preference[:name],
                '--columns', table_preference[:columns]]
      api_expects(:table_preferences, :create, params)
        .returns(table_preference)

      expected_result = success_result("Table preference created.\n")

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'update' do
    let(:cmd) { base_cmd << 'update' }

    it 'updates a table preference for a given table' do
      params = ['--user-id', user[:id],
                '--name', table_preference[:name],
                '--columns', ['A','B','C','D','E']]
      api_expects(:table_preferences, :update, params)
        .returns(table_preference)

      expected_result = success_result("Table preference updated.\n")

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'info' do
    let(:cmd) { base_cmd << 'info' }

    it 'shows table preference details of a given table' do
      params = ['--user-id', user[:id],
                '--name', table_preference[:name]]
      api_expects(:table_preferences, :show, params)
        .returns(table_preference)

      expected_result = success_result(/#{table_preference[:name]} | #{table_preference[:columns]}/)

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'delete' do
    let(:cmd) { base_cmd << 'delete' }

    it 'deletes a table preference for a given table' do
      params = ['--user-id', user[:id],
                '--name', table_preference[:name]]
      api_expects(:table_preferences, :destroy, params)
        .returns({})

      expected_result = success_result("Table preference deleted.\n")

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end
end
