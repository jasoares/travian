module Travian
  class ConnectionTimeout < Exception
    def initialize(host, trace)
      super("Error connecting to '#{host}' (#{trace})")
    end
  end

  class ConnectionRefused < Exception
    def initialize(host, trace)
      super("Connection to '#{host}' was refused(#{trace}).")
    end
  end
end
