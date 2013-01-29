module Travian
  module UriHelper

    def tld
      host[/travian\.(\w+(?:\.\w+)?)\/?$/]; $1
    end

    def subdomain
      host[/(\w+)\.travian/]; $1
    end

  end
end
