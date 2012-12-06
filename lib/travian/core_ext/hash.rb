require 'active_support/core_ext/hash/indifferent_access'

class Hash
  def self.from_js(hash, opts={})
    ruby_hash = hash.gsub(/,'/, ", ").gsub(/':/, ": ").gsub(/\{'/, "{ ")
    Hash[eval(ruby_hash)].with_indifferent_access
  end unless Hash.respond_to?(:from_js)
end
