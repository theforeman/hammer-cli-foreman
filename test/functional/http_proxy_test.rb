require File.join(File.dirname(__FILE__), 'test_helper')

describe 'httpproxy' do
  let(:http_proxy) do
    {
      :id => 1,
      :name => 'proxy1',
      :url => 'http://proxy.example.com',
      :username => 'user'
    }
  end

  it 'list a http proxy' do
    api_expects(:http_proxies, :index, 'List').with_params(
      'page' => 1, 'per_page' => 1000
    ).returns(index_response([http_proxy]))

    output = IndexMatcher.new([
      ['ID', 'NAME'],
      ['1',  'proxy1']
    ])
    expected_result = success_result(output)

    result = run_cmd(%w(http-proxy list))
    assert_cmd(expected_result, result)
  end

  it 'updates an http proxy' do
    params = ['--id', http_proxy[:id],
              '--password', 'katello']
    api_expects(:http_proxies, :update, params)
      .returns(http_proxy)

    expected_result = success_result("Http proxy updated.\n")

    result = run_cmd(%w(http-proxy update --id 1 --password katello))
    assert_cmd(expected_result, result)
  end

  it 'shows info on an http proxy' do
    params = ['--id', http_proxy[:id]]
    api_expects(:http_proxies, :show, params)
      .returns(http_proxy)
    expected_result = success_result("Id:       1\nName:     proxy1\nUsername: user\nURL:      http://proxy.example.com\n\n")
    result = run_cmd(%w(http-proxy info --id 1))
    assert_cmd(expected_result, result)
  end

  it 'creates an http proxy' do
    params = ['--url', http_proxy[:key],
              '--name', http_proxy[:name],
              '--password', 'foreman',
              '--username', http_proxy[:username]]
    api_expects(:http_proxies, :create, params)
      .returns(http_proxy)

    expected_result = success_result("Http proxy created.\n")

    result = run_cmd(%w(http-proxy create --url "http://proxy.example.com" --name proxy1 --username user --password foreman))
    assert_cmd(expected_result, result)
  end

  it 'deletes an http proxy' do
    expected_result = success_result("Http proxy deleted.\n")

    result = run_cmd(%w(http-proxy delete --id 1))
    # Skip this assertion until a version of awesome_print without warnings on Ruby 2.7 is available
    if RUBY_VERSION < '2.7'
      assert_cmd(expected_result, result)
    end
  end
end
