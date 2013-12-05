require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLIForeman::Output::Formatters::OSNameFormatter do
  it "formats the os name" do
    formatter = HammerCLIForeman::Output::Formatters::OSNameFormatter.new
    formatter.format({ :name => 'OS', :major => '1', :minor => '2' }).must_equal 'OS 1.2'
  end
  it "formats the os name with only major version" do
    formatter = HammerCLIForeman::Output::Formatters::OSNameFormatter.new
    formatter.format({ :name => 'Fedora', :major => '19'}).must_equal 'Fedora 19'
  end

  it "recovers when os is nil" do
    formatter = HammerCLIForeman::Output::Formatters::OSNameFormatter.new
    formatter.format(nil).must_equal nil
  end
end

describe HammerCLIForeman::Output::Formatters::ServerFormatter do
  it "formats the server" do
    formatter = HammerCLIForeman::Output::Formatters::ServerFormatter.new
    formatter.format({ :name => 'Server', :url => "URL"}).must_equal 'Server (URL)'
  end

  it "recovers when server is nil" do
    formatter = HammerCLIForeman::Output::Formatters::ServerFormatter.new
    formatter.format(nil).must_equal nil
  end
end
