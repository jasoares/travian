Given /^I (?:have|load) all travian hubs$/ do
  @hubs = Travian.hubs
end

Given /^the hub with code (\w+)$/ do |code|
  @hub = Travian.hubs[code.to_sym]
  @hub.should_not be_nil
end

Given /^the (\w+) hub$/ do |name|
  code = Travian::Hub::CODES.find {|k,v| v[:hub] == name }.first
  @hub = Travian.hubs[code]
end

Given /^the (\w+) hub borrows servers from the (\w+) hub$/ do |borrower, lender|
  step "the #{borrower} hub"
  @borrower = @hub
  @borrower.send(:borrows_servers?).should be true
  step "the #{lender} hub"
  @lender = @hub
  @borrower.mirrored_hub.should == @lender
end

When /^I fetch its servers$/ do
  @servers = @hub.servers
end

When /^I fetch (\w+)'s servers$/ do |name|
  step "the #{name} hub"
  step "I fetch its servers"
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

Then /^I should get the same servers as those from the (\w+) hub$/ do |name|
  servers = @hub.servers
  step "the #{name} hub"
  step "I fetch its servers"
  servers.should == @servers
end
