Feature: Change settings from outside the package
  As a developer
  I want to customize several settings
  So my admin panel is better suited to my purposes

  @dev
  Scenario: I want to change the root from '/admin'
    Given the current root is '/admin'
    And I want to change it to '/a'
    When I change the setting in Meteor.settings
    Then the new root should be '/a'

  @dev
  Scenario: I want a method for adding new buttons and functionality (publish)
    Given I have a collection
    And that collection is populated
    And has a field 'published' that is set to either 'true' or 'false'
    When I add a Houston.method that updates 'published' to 'true'
    Then an admin should have access to a 'publish' button
    And that publish button should change the status of 'published' to 'true'

  @dev
  Scenario: I want a method for adding new buttons and functionality (increment)
    Given I have a collection
    And that collection is populated
    And has a field 'counter' that is a number
    When I add a Houston.method that increments 'counter' by '1'
    Then an admin should have access to an 'increment'
    And that increment button should increment 'counter' by '1'

  @dev
  Scenario: I want to add custom menu items to the header (link)
    When I set Houston.menu to a link
    Then an admin should see a new header button with the correct title
    And that link should take me to that url

  # This will eventually be deprecated if we change the admin panel to an iframe.
  @dev
  Scenario: I want to add custom menu items to the header (template)
    When I set Houston.menu to a Blaze template
    Then an admin should see a new header button with the correct title
    And that link should render the proper template

  # This is not implemented yet. This will take care of React support. This will also be deprecated when we change to an iframe.
  @ignore
  Scenario: I want to add custom menu items to the header (component)
    When I set Houston.menu to a React component
    Then an admin should see a new header button with the correct title
    And that link should render the proper component

  # This is not implemented yet. This will be implemented when iframe is implemented
  @ignore
  Scenario: I want to add custom menu items to the header (route)
    When I set Houston.menu to a route
    Then an admin should see the new button
    And the button should link to the route
