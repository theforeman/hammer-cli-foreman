module HammerCLIForeman
  module Formatters

    def self.date_formatter string_date
      t = DateTime.parse(string_date.to_s)
      t.strftime("%Y/%m/%d %H:%M:%S")
    rescue ArgumentError
      ""
    end


    def self.parameters params
      params.collect do |p|
        p["parameter"]["name"] +" => "+ p["parameter"]["value"]
      end.join("\n")
    end

  end
end



