Feature: Automatic database discovery
  As an admin
  I want to have access to all my collections
  So that I can see them and edit them

  # The background will be run for every scenario
  Background:
    Given I am an admin
    And I have collections

  @dev
  Scenario: Non-empty collections automatically populate
    When I sign in
    Then I should have access to my collections

  @dev
  Scenario: Empty collections can be added manually
    When I sign in
    And I add an empty collection
    Then I should have access to my the collection I just added

  # This has not been implemented in the package yet
  @ignore
  Scenario: Simple Schema and Collection2 can be used to set schema
    When I sign in
    And I add an empty collection
    Then I should have access to my collections
