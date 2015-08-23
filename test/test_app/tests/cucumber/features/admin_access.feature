Feature: Administrator access
  As an admin
  I want to have access to everything the admin should have access to
  So that I can see and edit my data

  # The background will be run for every scenario
  Background:
    Given I am an admin

  @dev
  Scenario: I want to see a list of databases
    Given I have a collection
    And my collection was picked up by Houston
    When I access the admin panel
    Then my collections should be visible

  @dev
  Scenario: I want to add new admins
    Given there is at least one other user
    When I make that user an admin
    Then that user should now be an admin

  @dev
  Scenario: I want my column headers to correspond to keys
    Given I have a collection
    And that collection has keys
    When I access the admin panel
    Then I should see column headers with titles corresponding to keys
    And I should see the values corresponding to those keys in columns

  @dev
  Scenario: I want to dd anew items to a collection
    Given I have a collection
    And that collection was picked up by Houston
    When I add a new item to a collection
    Then that item should be in the collection
    And the interface should update with the new item

  @dev
  Scenario: I want to filter results from a collection
    Given I have a collection
    And that collection was picked up by Houston
    When I filter by a category
    Then the results should be filtered properly

  @dev
  Scenario: I want Houston to infer the schema automatically
    Given I have a collection
    And that collection was picked up by Houston
    And that collection has more than one kind of data
    When I access the interface to add new item
    Then the input types should reflect the schema of the collection

  @dev
  Scenario: I want to update or delete an item from the update interface
    Given I have a collection
    And that collection was picked up by Houston
    When I select that document to be updated
    Then I should be able to delete that document
    And I should be able to update that document

  @dev
  Scenario: I want my collections separated into pages
    Given I have a collection
    And that collection was picked up by Houston
    And that collection has more than 100 items
    When I look at the table
    Then my results should be separated into pages

  # This is not implemented yet. This would also replace the pagination test above.
  @ignore
  Scenario: I want my entire collection visible at one time
    Given I have a collection
    And that collection was picked up by Houston
    And that collection has more than 100 items
    When I look at the table
    Then I should see all my results without pagination
