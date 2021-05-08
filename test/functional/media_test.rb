require File.join(File.dirname(__FILE__), 'test_helper')

describe 'medium' do
  describe 'list' do
    before do
      @cmd = %w[medium list]
      @media = [{
        id: 1,
        name: 'CentOS mirror',
        path: 'http://mirror.centos.org/centos/$major/os/$arch',
        os_family: 'Redhat',
        operating_systems: [],
        locations: [],
        organizations: []
      }]
    end

    it 'should return a list of media' do
      api_expects(:media, :index, 'List media').returns(@media)

      output = IndexMatcher.new([
                                  ['ID', 'NAME', 'PATH'],
                                  ['1', 'CentOS mirror', 'http://mirror.centos.org/centos/$major/os/$arch']
                                ])
      expected_result = success_result(output)

      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end
  end

  describe 'info' do
    before do
      @cmd = ['medium', 'info']
      @medium = {
        id: 1,
        name: 'CentOS mirror',
        path: 'http://mirror.centos.org/centos/$major/os/$arch',
        os_family: 'Redhat',
        operating_systems: [],
        locations: [],
        organizations: []
      }
    end

    it 'should return the info of a medium' do
      params = ['--id', 1]
      api_expects(:media, :show, 'Info medium').returns(@medium)

      output = OutputMatcher.new([
                                   'Id:        1',
                                   'Name:      CentOS mirror',
                                   'Path:      http://mirror.centos.org/centos/$major/os/$arch',
                                   'OS Family: Redhat'
                                 ])

      expected_result = success_result(output)
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'create' do
    before do
      @cmd = %w(medium create)
    end

    it 'should print error missing argument name and path' do
      expected_result = "Could not create the installation medium:\n  Missing arguments for '--name', '--path'.\n"


      result = run_cmd(@cmd)
      assert_match(expected_result, result.err)
    end

    it 'should create a media' do
      params = ['--name=CentOS mirror', '--path=http://mirror.centos.org/centos/$major/os/$arch']

      api_expects(:media, :create) do |params|
        (params['medium']['name'] == 'CentOS mirror')
        (params['medium']['path'] == 'http://mirror.centos.org/centos/$major/os/$arch')
      end

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Installation medium created.\n"), result)
    end
  end

  describe 'delete' do
    before do
      @cmd = %w(medium delete)
    end

    it 'should print error missing argument id' do
      expected_result = "Could not delete the installation media:\n  Missing arguments for '--id'.\n"

      api_expects_no_call

      result = run_cmd(@cmd)
      assert_match(expected_result, result.err)
    end

    it 'should delete a media' do
      params = ['--id=1']

      api_expects(:media, :destroy, 'Delete a media').with_params(id: '1')

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Installation medium deleted.\n"), result)
    end
  end

  describe 'update' do
    before do
      @cmd = ['medium', 'update']
    end

    it 'should update a media' do
      params = ['--id=1', '--new-name=CentOS mirror test']

      api_expects(:media, :update, 'Update a media') do |params|
        (params['medium']['id'] == '1')
        (params['medium']['name'] == 'CentOS mirror test')
      end

      result = run_cmd(@cmd + params)
      assert_cmd(success_result("Installation medium updated.\n"), result)
    end

    it 'updates nothing without medium related parameters' do
      params = %w[--id=1]

      api_expects(:media, :update, 'Update medium with no params').returns({})

      expected_result = success_result("Nothing to update.\n")

      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end
  end
end
