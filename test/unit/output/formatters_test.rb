require File.join(File.dirname(__FILE__), '../test_helper')


describe HammerCLIForeman::Output::Formatters::SingleReferenceFormatter do

  let(:formatter) { HammerCLIForeman::Output::Formatters::SingleReferenceFormatter.new }
  let(:reference) do
    {
      :server_id => 1,
      :server_name => 'Server',
    }
  end

  let(:reference_str_keys) do
    reference.inject({}) do |new_ref, (key, value)|
      new_ref.update(key.to_s => value)
    end
  end

  context "with symbol keys" do
    it "formats name" do
      options = {:key => :server}
      formatter.format(reference, options).must_equal 'Server'
    end

    it "formats id" do
      options = {:key => :server, :context => {:show_ids => true}}
      formatter.format(reference, options).must_equal 'Server (id: 1)'
    end
  end

  context "with string keys" do
    it "formats name" do
      options = {:key => :server}
      formatter.format(reference_str_keys, options).must_equal 'Server'
    end

    it "formats id" do
      options = {:key => :server, :context => {:show_ids => true}}
      formatter.format(reference_str_keys, options).must_equal 'Server (id: 1)'
    end
  end

end

describe HammerCLIForeman::Output::Formatters::ReferenceFormatter do

  let(:formatter) { HammerCLIForeman::Output::Formatters::ReferenceFormatter.new }
  let(:reference) do
    {
      :id => 1,
      :another_id => 2,
      :name => 'Server',
      :another_name => 'SERVER',
      :url => "URL",
      :desc => "Description"
    }
  end


  it "recovers when the resource is missing" do
    formatter.format(nil).must_equal ''
  end

  context "with symbol keys" do
    let(:reference_sym_keys) do
      reference
    end

    it "formats name" do
      formatter.format(reference_sym_keys, {}).must_equal 'Server'
    end

    it "can override name key" do
      options = {:name_key => :another_name}
      formatter.format(reference_sym_keys, options).must_equal 'SERVER'
    end

    it "formats id" do
      options = {:context => {:show_ids => true}}
      formatter.format(reference_sym_keys, options).must_equal 'Server (id: 1)'
    end

    it "can override id key" do
      options = {:id_key => :another_id, :context => {:show_ids => true}}
      formatter.format(reference_sym_keys, options).must_equal 'Server (id: 2)'
    end

    it "formats details" do
      options = {:details => :url}
      formatter.format(reference_sym_keys, options).must_equal 'Server (URL)'
    end

    it "formats multiple details" do
      options = {:details => [:url, :desc]}
      formatter.format(reference_sym_keys, options).must_equal 'Server (URL, Description)'
    end

    it "formats details and id" do
      options = {:context => {:show_ids => true}, :details => [:url, :desc]}
      formatter.format(reference_sym_keys, options).must_equal 'Server (URL, Description, id: 1)'
    end
  end

  context "with string keys" do
    let(:reference_str_keys) do
      reference.inject({}) do |new_ref, (key, value)|
        new_ref.update(key.to_s => value)
      end
    end

    it "formats name" do
      formatter.format(reference_str_keys, {}).must_equal 'Server'
    end

    it "can override name key" do
      options = {:name_key => :another_name}
      formatter.format(reference_str_keys, options).must_equal 'SERVER'
    end

    it "formats id" do
      options = {:context => {:show_ids => true}}
      formatter.format(reference_str_keys, options).must_equal 'Server (id: 1)'
    end

    it "can override id key" do
      options = {:id_key => :another_id, :context => {:show_ids => true}}
      formatter.format(reference_str_keys, options).must_equal 'Server (id: 2)'
    end

    it "formats details" do
      options = {:details => :url}
      formatter.format(reference_str_keys, options).must_equal 'Server (URL)'
    end

    it "formats multiple details" do
      options = {:details => [:url, :desc]}
      formatter.format(reference_str_keys, options).must_equal 'Server (URL, Description)'
    end

    it "formats details and id" do
      options = {:context => {:show_ids => true}, :details => [:url, :desc]}
      formatter.format(reference_str_keys, options).must_equal 'Server (URL, Description, id: 1)'
    end
  end

end
