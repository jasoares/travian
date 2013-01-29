$: << File.expand_path("../../lib", File.dirname(__FILE__))
$: << File.expand_path("../../spec", File.dirname(__FILE__))
require 'rspec'
require 'spec_helper'
require 'travian'

if ENV['ONLINE']
  FakeWeb.allow_net_connect = true
else
  tlds = %w{ co.kr com pt de net com.mx com.ar cl co.nz com.au in }
  tlds.each {|tld| fake_hub "www.travian.#{tld}" }
  fake 'arabia.travian.com'
  fake 'arabia.travian.com/serverLogin.php', :post
end
