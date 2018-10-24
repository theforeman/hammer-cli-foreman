module HammerCLIForeman
  def self.version
    @version ||= Gem::Version.new '0.16-develop'
  end
end
