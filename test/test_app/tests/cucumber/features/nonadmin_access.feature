Feature: Non-administrator access
  As a non-admin
  I want to be able to become the admin or sign in
  So that I can see and edit my data

  # The background will be run for every scenario
  Background:
    Given I am not an admin

  @dev
  Scenario: I am the first person using this app and I want to claim adminship
    Given there are no other admins
    When I claim the adminship
    Then I become the admin

  @dev
  Scenario: I want to sign in
    Given I am not signed in as admin
    And I have admin status
    When I sign in
    Then I have access to admin panel

  @dev
  Scenario: I want to sign in but I am not an admin
    Given I am not an admin
    When I sign in
    Then I am not given access to the admin panel
