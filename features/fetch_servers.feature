Feature: Fetch Servers

  As a Travian 3rd party developer
  I need to know which servers are running, stopped and restarting
  And the information of each server
  So that I can keep track and persist that information over time

  Scenario: Loading portuguese servers
    Given the Portugal hub
    When I fetch its servers
    Then I should have 10 servers

  Scenario Outline: Server State
    Given I fetch the server <host>
    Then I should know it started on <start_date>
    And the running status is <running>
    And its ended status should be <ended>
    And its restarting status should be <restarting>
    And its going to restart at <restart date>
    And I should know it has <players> players

    Examples:
      | host                  | start_date              | running | ended | restarting | restart date            | players |
      | tx3.travian.pt        | 06/09/2012 00:00 +00:00 | true    | false | false      | nil                     | 3101    |
      | arabiatx4.travian.com | 25/11/2012 00:00 +00:00 | true    | false | false      | nil                     | 9732    |
      | ts5.travian.de        | 25/11/2012 00:00 +00:00 | true    | false | false      | nil                     | 8516    |
      | ts4.travian.de        | nil                     | false   | true  | true       | 21/01/2013 06:00 +01:00 | 0       |
      | ts6.travian.de        | nil                     | false   | true  | false      | nil                     | 0       |

  Scenario Outline: Server information
    Given I have the server <host>
    Then I should know it is <speed> times fast
    And that its name is <name>
    And its identifier is <world id>
    And its internal identifier is <server id>
    And its on v<version>
    And <code> should be its code

    Examples:
      | host                  | code      | name         | speed | world id | server id | version |
      | tx3.travian.pt        | tx3       | Speed 3x     | 3     | ptx18    | ptx       | 4.0     |
      | arabiatx4.travian.com | arabiatx4 | arabia 4x    | 4     | sy1717   | sy17      | 4.0     |
      | ts5.travian.de        | ts5       | Welt 5       | 1     | de55     | de5       | 4.0     |
      | ts4.travian.de        | ts4       | Welt 4       | 1     | de44     | de4       | 4.0     |
      | ts6.travian.de        | ts6       | nil          | 1     | de66     | de6       | 4.0     |
