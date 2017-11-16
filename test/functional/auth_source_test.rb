require File.join(File.dirname(__FILE__), '..', 'test_helper')

describe 'AuthSource' do
  let(:auth_source_ldap) do
    {
        :id => 1,
        :name => 'MyLDAP',
        :type => 'AuthSourceLdap'
    }
  end

  let(:auth_source_external) do
    {
        :id => 2,
        :name => 'MyExternal',
        :type => 'AuthSourceExternal'
    }
  end

  let(:auth_source_internal) do
    {
        :id => 3,
        :name => 'MyInternal',
        :type => 'AuthSourceInternal'
    }
  end

  describe 'list command' do
    before do
      @cmd = %w(auth-source list)
    end

    params = []

    it 'lists all authentication sources' do
      api_expects(:auth_sources, :index, 'List').with_params(
          'page' => 1, 'per_page' => 1000
      ).returns(index_response([auth_source_ldap, auth_source_external, auth_source_internal]))

      output = IndexMatcher.new([
                                    ['ID', 'NAME',  'TYPE OF AUTH SOURCE'],
                                    ['1',  'MyLDAP',  'AuthSourceLdap'],
                                    ['2',  'MyExternal', 'AuthSourceExternal'],
                                    ['3',  'MyInternal', 'AuthSourceInternal']
                                ])
      expected_result = success_result(output)

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

  end

end
