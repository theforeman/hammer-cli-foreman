module HammerCLIForeman
  def self.version
    @version ||= Gem::Version.new '0.19-develop'
  end
end
