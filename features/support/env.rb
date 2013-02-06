$: << File.expand_path("../../lib", File.dirname(__FILE__))
$: << File.expand_path("../../spec", File.dirname(__FILE__))
require 'rspec'
require 'spec_helper'
require 'travian'

if ENV['ONLINE']
  FakeWeb.allow_net_connect = true
else
  Timecop.freeze(Time.utc(2012,12,30,23,0,0))
  fake 'www.travian.com'
  tlds = %w{ co.kr com pt de net com.mx com.ar cl co.nz com.au in }
  tlds.each {|tld| fake_hub "www.travian.#{tld}" }
  fake 'arabia.travian.com/serverLogin.php', :post
  fake 'arabia.travian.com/register.php', :post
  fake 'tx3.travian.pt'
  fake 'arabiatx4.travian.com'
  fake 'ts4.travian.de'
  fake 'ts5.travian.de'
  fake 'ts6.travian.de'
end
