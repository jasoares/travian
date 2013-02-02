Given /^I (?:fetch|have) the server (\w+\.travian\.\w+(?:\.\w+)?)$/ do |uri|
  @server = Travian::Server(uri)
  @server.should_not be nil
  @server.host.should == uri
end

Then /^(?:that)? its name is ([\w\s\d]+)$/ do |name|
  @server.name.should == (name == "nil" ? nil : name)
end

Then /^(\w+\d+) should be its code$/ do |code|
  @server.code.should == code
end

Then /^(?:I should know)? it is (\d+) times fast$/ do |speed|
  @server.speed.should == speed.to_i
end

Then /^(?:I should know)? it has (\d+|nil) players$/ do |players|
  @server.players.should == (players == "nil" ? nil : players.to_i)
end

Then /^its identifier is (\w+\d+)$/ do |world_id|
  @server.world_id.should == world_id
end

Then /^its on v(\d\.\d)$/ do |version|
  @server.version.should == version
end

Then /^(?:the|its) (running|restarting|ended) status (?:is|should be) (true|false)$/ do |state, status|
  @server.send("#{state}?".to_sym).should == (status == "true")
end

Then /^I should have (\d+) servers$/ do |n|
  @servers.should have(n).servers
end

Then /^its going to restart at (.+)$/ do |restart_date|
  restart_date = restart_date == 'nil' ? nil : DateTime.strptime(restart_date, "%d/%m/%Y %H:%M %:z")
  @server.restart_date.should == restart_date
end

Then /^(?:I should know)? it started on (.+)$/ do |start_date|
  start_date = start_date == 'nil' ? nil : DateTime.strptime(start_date, "%d/%m/%Y %H:%M %:z")
  @server.start_date.should == start_date
end
