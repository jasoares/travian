Given /^I (?:have|load) all travian hubs$/ do
  @hubs = Travian.hubs
end

Given /^the hub with code (\w+)$/ do |code|
  @hub = Travian.hubs[code.to_sym]
  @hub.should_not be_nil
end

Then /^I should have (\d+) hubs$/ do |n|
  @hubs.should have(n).hubs
end

Then /^I should have (\d+) mirror hubs?$/ do |n|
  @hubs.select(&:mirror?).should have(n).mirror_hubs
end

Then /^its mirrored host should be (.+)$/ do |value|
  value = value == "nil" ? nil : value
  @hub.mirrored_host.should == value
end

Then /^its (\w+) status should be (\w+)$/ do |method, value|
  value = value == "true"
  @hub.send("#{method}?".to_sym).should be value
end

Then /^its (\w+) should be (.+)$/ do |attr, value|
  @hub.send(attr.to_sym).should == value
end
