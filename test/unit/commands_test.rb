require File.join(File.dirname(__FILE__), 'test_helper')
require 'hammer_cli'


describe HammerCLIForeman do

  context "collection_to_common_format" do

    let(:kind) { { "name" => "PXELinux", "id" => 1 } }

    it "should convert old API format" do
      old_format = [
        {
          "template_kind" => kind
        }
      ]

      set = HammerCLIForeman.collection_to_common_format(old_format)
      set.must_be_kind_of HammerCLI::Output::RecordCollection
      set.first.must_equal(kind)
    end

    it "should convert common API format" do
      common_format = [ kind ]

      set = HammerCLIForeman.collection_to_common_format(common_format)
      set.must_be_kind_of HammerCLI::Output::RecordCollection
      set.first.must_equal(kind)
    end

    it "should convert new API format" do
      new_format = {
        "total" => 1,
        "subtotal" => 1,
        "page" => 1,
        "per_page" => 20,
        "search" => nil,
        "sort" => {
          "by" => nil,
          "order" => nil
        },
        "results" => [ kind ]
      }

      set = HammerCLIForeman.collection_to_common_format(new_format)
      set.must_be_kind_of HammerCLI::Output::RecordCollection
      set.first.must_equal(kind)
    end

    it "should rise error on unexpected format" do
      proc { HammerCLIForeman.collection_to_common_format('unexpected') }.must_raise RuntimeError
    end

  end


  context "record_to_common_format" do

    let(:arch) { { "name" => "x86_64", "id" => 1 } }

    it "should convert old API format" do
      old_format = {
        "architecture" => arch
      }

      rec = HammerCLIForeman.record_to_common_format(old_format)
      rec.must_equal(arch)
    end

    it "should convert common API format" do
      common_format = arch

      rec = HammerCLIForeman.record_to_common_format(common_format)
      rec.must_equal(arch)

    end

  end
end
