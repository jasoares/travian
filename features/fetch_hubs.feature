Feature: Fetch Hubs

  As a Travian 3rd party developer
  I need to know which hubs are running
  And the status/info for each hub
  So that I can keep track of the moving parts

  @slow
  Scenario: Loading all hubs
    Given I load all travian hubs
    Then I should have 55 hubs
    And I should have 4 mirror hubs

  Scenario Outline: Hub information
    Given the hub with code <code>
    Then its host should be <host>
    And its name should be <name>
    And its language should be <language>
    And its mirror status should be <mirror>
    And its mirrored host should be <mirrored host>
    And its redirected status should be <redirected>

    Examples:
      | code     |          host              |     name    | language | mirror | mirrored host              | redirected |
      | pt       | http://www.travian.pt/     | Portugal    | pt       | false  | nil                        | false      |
      | de       | http://www.travian.de/     | Germany     | de       | false  | nil                        | false      |
      | net      | http://www.travian.net/    | Spain       | es       | false  | nil                        | false      |
      | kr       | http://www.travian.co.kr/  | South Korea | en       | true   | http://www.travian.com/    | true       |
      | mx       | http://www.travian.com.mx/ | Mexico      | es       | true   | http://www.travian.cl/     | false      |
      | nz       | http://www.travian.co.nz/  | New Zealand | en       | true   | http://www.travian.com.au/ | true       |
      | ar       | http://www.travian.com.ar/ | Argentina   | es       | true   | http://www.travian.cl/     | false      |
      | arabia   | http://arabia.travian.com/ | Arabia      | ar       | false  | nil                        | false      |
      | in       | http://www.travian.in/     | India       | in       | false  | nil                        | false      |
