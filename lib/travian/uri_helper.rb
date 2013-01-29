module Travian
  module UriHelper

    def tld
      UriHelper.tld(host)
    end

    def subdomain
      UriHelper.subdomain(host)
    end

    class << self

      def tld(host)
        host[/travian\.(\w+(?:\.\w+)?)\/?$/]; $1
      end

      def subdomain(host)
        host[/(\w+)\.travian/]; $1
      end

    end
  end
end
