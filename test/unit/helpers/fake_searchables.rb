

class FakeSearchables

  def initialize(searchable_fields, editable_fields = [])
    @searchables = []
    @searchables += searchable_fields.collect do |name|
      HammerCLIForeman::Searchable.new(name, "Search by #{name}", :editable => false)
    end
    @searchables += editable_fields.collect do |name|
      HammerCLIForeman::Searchable.new(name, "Search by #{name}", :editable => true)
    end
  end

  def for(resource)
    @searchables
  end

end
