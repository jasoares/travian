module Travian
  class ConnectionTimeout < Exception
    def initialize(host, trace)
      super("Error connecting to '#{host}' (#{trace})")
    end
  end
end
