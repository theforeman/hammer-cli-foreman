require File.join(File.dirname(__FILE__), '../test_helper')

describe HammerCLIForeman::Output::Formatters::StructuredReferenceFormatter do

  let(:formatter) { HammerCLIForeman::Output::Formatters::StructuredReferenceFormatter.new }
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

  context 'with symbol keys' do
    it 'formats name' do
      options = {:display_field_key => :server_name}
      formatter.format(reference, options).must_equal('Name' => "#{reference_str_keys['server_name']}")
    end

    it 'formats id' do
      options = {:display_field_key => :server_name,
                 :details => {:structured_label => 'Id', :key => :server_id}}
      formatter.format(reference, options)
        .must_equal('Name' => "#{reference_str_keys['server_name']}", 'Id' => reference_str_keys['server_id'])
    end
  end

  context 'with string keys' do
    it 'formats name' do
      options = {:display_field_key => :server_name}
      formatter.format(reference_str_keys, options).must_equal('Name' => "#{reference_str_keys['server_name']}")
    end

    it 'formats id' do
      options = {:display_field_key => :server_name,
                 :details => {:structured_label => 'Id', :key => :server_id}}
      formatter.format(reference_str_keys, options).must_equal('Name' => "#{reference_str_keys['server_name']}", 'Id' => reference_str_keys['server_id'])
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

  it 'recovers when the resource is missing' do
    formatter.format(nil).must_equal ''
  end

  context 'with symbol keys' do
    let(:reference_sym_keys) do
      reference
    end

    it 'formats name' do
      formatter.format(reference_sym_keys, {}).must_equal("#{reference_sym_keys[:name]}")
    end

    it 'can override name key' do
      options = {:display_field_key => :another_name}
      formatter.format(reference_sym_keys, options).must_equal("#{reference_sym_keys[:another_name]}")
    end

    it 'formats id' do
      options = {:details => {:key => :id, :label => {:target => 'Id'}}, :context => {:show_ids => true}}
      formatter.format(reference_sym_keys, options)
        .must_equal("Server (Id: #{reference_sym_keys[:id]})")
    end

    it 'formats details' do
      options = { :details => { :label => _('url'), :key => :url } }
      formatter.format(reference_sym_keys, options).must_equal("Server (url: #{reference_sym_keys[:url]})")
    end

    it 'formats multiple details' do
      options = { :details => [{ :label => _('url'), :key => :url },
                               {:label => _('desc'), :key => :desc }]
                }
      formatter.format(reference_sym_keys, options)
        .must_equal("Server (url: #{reference_sym_keys[:url]}, desc: #{reference_sym_keys[:desc]})")
    end

    it 'formats details and id' do
      options = {:context => {:show_ids => true},
                 :details => [{:label => _('url'), :key => :url },
                              {:label => _('desc'), :key => :desc },
                              {:label => _('Id'), :key => :id }]
                }
      formatter.format(reference_sym_keys, options)
        .must_equal("Server (url: #{reference_sym_keys[:url]}, desc: #{reference_sym_keys[:desc]}, Id: #{reference_sym_keys[:id]})")
    end
  end

  context 'with string keys' do
    let(:reference_str_keys) do
      reference.inject({}) do |new_ref, (key, value)|
        new_ref.update(key.to_s => value)
      end
    end

    it 'formats name' do
      formatter.format(reference_str_keys, {}).must_equal("#{reference_str_keys['name']}")
    end

    it 'can override name key' do
      options = {:display_field_key => :another_name}
      formatter.format(reference_str_keys, options).must_equal("#{reference_str_keys['another_name']}")
    end

    it 'formats id when show_ids is true' do
      options = {:details => {:label => {:target => 'Id'}, :key => :id, :id => 1}, :context => {:show_ids => true}}
      formatter.format(reference_str_keys, options)
               .must_equal("Server (Id: #{reference_str_keys['id']})")
    end

    it 'does not formats id when show_ids is false' do
      options = {:details => {:label => 'Id', :key => :id,  :id => 1}, :context => {:show_ids => false}}
      formatter.format(reference_str_keys, options)
               .must_equal("#{reference_str_keys['name']}")
    end

    it 'formats details' do
      options = { :details => { :label => _('url'), :key => :url } }
      formatter.format(reference_str_keys, options)
               .must_equal("Server (url: #{reference_str_keys['url']})")
    end

    it 'formats multiple details' do
      options = { :details => [{ :label => _('url'), :key => :url },
                               { :label => _('desc'), :key => :desc }] }
      formatter.format(reference_str_keys, options)
               .must_equal("Server (url: #{reference_str_keys['url']}, desc: #{reference_str_keys['desc']})")
    end

    it 'formats details and id' do
      options = {:context => { :show_ids => true },
                 :details => [{ :label => _('url'), :key => :url },
                              { :label => _('desc'), :key => :desc },
                              { :label => _('Id'), :key => :id }] }
      formatter.format(reference_str_keys, options)
               .must_equal("Server (url: #{reference_str_keys['url']}, desc: #{reference_str_keys['desc']}, Id: #{reference_str_keys['id']})")
    end
  end

end
