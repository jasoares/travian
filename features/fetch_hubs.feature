Feature: Fetch Hubs

  As a Travian 3rd party developer
  I need to know which hubs are running
  And the status/info for each hub
  So that I can keep track of the moving parts

  @slow @online
  Scenario: Loading all hubs
    Given I load all travian hubs
    Then I should have 56 hubs
    And I should have 4 mirror hubs

  Scenario: Loading mirror which borrows servers
    Given the Mexico hub borrows servers from the Chile hub
    When I fetch Mexico's servers
    Then I should get the same servers as those from the Chile hub

  Scenario: Loading mirror which redirects to main hub
    Given the South Korea hub redirects to the International hub
    When I fetch South Korea's servers
    Then I should get the same servers as those from the International hub

  Scenario Outline: Hub information
    Given the hub with code <code>
    Then its host should be <host>
    And its name should be <name>
    And its language should be <language>
    And its mirror status should be <mirror>
    And its mirrored host should be <mirrored host>
    And its redirected status should be <redirected>

    Examples:
      | code     | host               | name        | language | mirror | mirrored host      | redirected |
      | pt       | www.travian.pt     | Portugal    | pt       | false  | nil                | false      |
      | de       | www.travian.de     | Germany     | de       | false  | nil                | false      |
      | net      | www.travian.net    | Spain       | es       | false  | nil                | false      |
      | kr       | www.travian.co.kr  | South Korea | en       | true   | www.travian.com    | true       |
      | mx       | www.travian.com.mx | Mexico      | es       | true   | www.travian.cl     | false      |
      | nz       | www.travian.co.nz  | New Zealand | en       | true   | www.travian.com.au | true       |
      | ar       | www.travian.com.ar | Argentina   | es       | true   | www.travian.cl     | false      |
      | arabia   | arabia.travian.com | Arabia      | ar       | false  | nil                | false      |
      | in       | www.travian.in     | India       | in       | false  | nil                | false      |
