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
    When I sign in
    Then I should have access to my collections

  @dev
  Scenario: I want to be able to manually add empty collections
    When I sign in
    And I add an empty collection
    Then I should have access to my the collection I just added

  # This has not been implemented in the package yet
  @ignore
  Scenario: I want to be able to specify a schema with Simple Schema and Collection2
    When I sign in
    And I add an empty collection
    Then I should have access to my collections
