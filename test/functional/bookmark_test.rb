# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'test_helper')

describe 'bookmark' do
  describe 'list' do
    before do
      @cmd = %w[bookmark list]
      @bookmarks = [{
        id: 1,
        name: 'active',
        controller: 'hosts',
        owner_id: 1,
        owner_type: 'User'
      }]
    end

    it 'should return a list of bookmarks' do
      api_expects(:bookmarks, :index, 'List bookmarks').returns(@bookmarks)

      output = IndexMatcher.new([
                                  %w[ID NAME CONTROLLER OWNER\ ID OWNER\ TYPE],
                                  %w[1 active hosts 1 User]
                                ])
      expected_result = success_result(output)

      result = run_cmd(@cmd)
      assert_cmd(expected_result, result)
    end
  end

  describe 'info' do
    before do
      @cmd = %w[bookmark info]
      @bookmark = {
        id: 1,
        name: 'active',
        controller: 'hosts',
        owner_id: 1,
        owner_type: 'User'
      }
    end

    it 'should return the info of a bookmark' do
      params = ['--id=1']
      api_expects(:bookmarks, :show, 'Info bookmark').returns(@bookmark)
      output = OutputMatcher.new([
                                   'Id:         1',
                                   'Name:       active',
                                   'Controller: hosts',
                                   'Owner Id:   1',
                                   'Owner Type: User'
                                 ])

      expected_result = success_result(output)
      result = run_cmd(@cmd + params)
      assert_cmd(expected_result, result)
    end

    describe 'create bookmark' do
      before do
        @cmd = %w[bookmark create]
      end

      it 'should create a bookmark' do
        params = ['--name=newBookmark', '--controller=hosts', '--query=status = failed']
        api_expects(:bookmarks, :create, 'Create bookmark') do |params|
          (params['bookmark']['name'] == 'newBookmark')
          (params['bookmark']['controller'] == 'hosts')
          (params['bookmark']['query'] == 'status = failed')
        end
        result = run_cmd(@cmd + params)
        assert_cmd(success_result("Bookmark %<name>s created.\n"), result)
      end

      it 'should print error on missing --name' do
        params = ['--controller=hosts', '--query=status = failed']
        expected_result = CommandExpectation.new
        expected_result.expected_err =
          ['Failed to create  bookmark:',
           "  Missing arguments for '--name'",
           ''].join("\n")
        expected_result.expected_exit_code = HammerCLI::EX_USAGE

        api_expects_no_call

        result = run_cmd(@cmd + params)
        assert_cmd(expected_result, result)
      end

      it 'should print error on missing --controller' do
        params = ['--name=newBookmark', '--query=status = failed']
        expected_result = CommandExpectation.new
        expected_result.expected_err =
          ['Failed to create  bookmark:',
           "  Missing arguments for '--controller'",
           ''].join("\n")
        expected_result.expected_exit_code = HammerCLI::EX_USAGE
        api_expects_no_call

        result = run_cmd(@cmd + params)

        assert_cmd(expected_result, result)
      end

      it 'should print error on missing --query' do
        params = ['--name=newBookmark', '--controller=hosts']

        expected_result = CommandExpectation.new
        expected_result.expected_err =
          ['Failed to create  bookmark:',
           "  Missing arguments for '--query'",
           ''].join("\n")
        expected_result.expected_exit_code = HammerCLI::EX_USAGE

        api_expects_no_call

        result = run_cmd(@cmd + params)

        assert_cmd(expected_result, result)
      end
    end

    describe 'update bookmark' do
      before do
        @cmd = %w[bookmark update]
        @bookmark = {
          "id": 1,
          'name': 'bookmark-2',
          'controller': 'hosts',
          'query': 'status = failed',
          'owner_id': 1,
          'owner_type': 'User'
        }
      end

      it 'allows minimal options' do
        api_expects(:bookmarks, :update) do |par|
          par['id'] == '1'
        end
        run_cmd(%w[bookmark update --id 1])
      end

      it 'update bookmark' do
        params = ['--id=1', '--new-name=bookmark-2', '--controller=hosts', '--query=status != failed']
        api_expects(:bookmarks, :update, 'Update the bookmark') do |params|
          (params['bookmark']['id'] = 1)
          (params['bookmark']['name'] = 'bookmark-2')
          (params['bookmark']['controller'] = 'hosts')
          (params['bookmark']['query'] = 'status != failed')
        end
        result = run_cmd(@cmd + params)
        assert_cmd(success_result("Bookmark %<name>s updated successfully.\n"), result)
      end
    end

    describe 'delete bookmark' do
      before do
        @cmd = %w[bookmark delete]

        @bookmark = {
          "id": 1,
          'name': 'bookmark-2',
          'controller': 'hosts',
          'query': 'status = failed',
          'owner_id': 1,
          'owner_type': 'User'
        }
      end

      it 'delete bookmark' do
        params = ['--id=1']
        api_expects(:bookmarks, :destroy, id: 1).returns({})
        result = run_cmd(@cmd + params)
        assert_cmd(success_result("Bookmark deleted successfully.\n"), result)
      end

      it 'should print error on missing --id' do
        params = []

        expected_result = CommandExpectation.new
        expected_result.expected_err =
          ['Failed to delete bookmark:',
           "  Missing arguments for '--id'",
           ''].join("\n")
        expected_result.expected_exit_code = HammerCLI::EX_USAGE
        api_expects_no_call
        result = run_cmd(@cmd + params)
        assert_cmd(expected_result, result)
      end
    end
  end
end
