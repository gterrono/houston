Feature: Automatic database discovery
  As an admin
  I want to have access to all my collections
  So that I can see them and edit them

  # The background will be run for every scenario
  Background:
    Given I am an admin
    And I have more than one collection

  @dev
  Scenario: I want non-empty collections to automatically populate
    Then I should have access to my collections

  @dev
  Scenario: I want to manually add empty collections
    Given I am a developer
    And some of my collections were not discovered
    When I add an empty collection
    Then the admin should have access to my the collection I just added

  @dev
  Scenario: I don't want to see users and houston_admin by default
    Then I should not see users or houston_admin

  @dev
  Scenario: I want to see users and houston_admin
    Given I am a developer
    When I add users and houston_admin
    Then the admin should have access to those collections

  # This has not been implemented in the package yet
  @ignore
  Scenario: I want to specify a schema with Simple Schema and Collection2
    Given I am a developer
    And I am using Simple Schema and Collection2
    When I specify a schema
    Then the admin should see the collection with the specified schema
