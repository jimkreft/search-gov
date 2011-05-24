Feature: Forms Home Page and Search
  In order to find government related forms
  a U.S. Citizen
  wants to search for forms

  Scenario: Forms search
    Given I am on the homepage
    When I follow "Forms" in the search navigation
    Then I should be on the forms home page
    And I should not see "ROBOTS" meta tag
    And I should see "Federal Government Forms Catalog has moved and is different."
    When I fill in "query" with "White House"
    And I press "Search Forms"
    Then I should be on the forms search page
    And I should see "NOINDEX, NOFOLLOW" in "ROBOTS" meta tag
    And I should see 10 search results
    And I should see "Next"

  Scenario: A nonsense search
    Given I am on the forms home page
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I submit the search form
    Then I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."

  Scenario: Doing a blank search from the forms home page
    Given I am on the forms home page
    When I submit the search form
    Then I should be on the forms home page

  Scenario: Doing a blank search from the forms SERP
    Given I am on the forms search page
    When I submit the search form
    Then I should be on the forms home page

  Scenario: A unicode search
    Given I am on the forms home page
    When I fill in "query" with "البيت الأبيض"
    And I submit the search form
    Then I should see "البيت الأبيض"

  Scenario: No Spanish or Advanced links
    Given I am on the forms home page
    Then I should not see "Advanced Search"
    And I should not see "Busque en español"

    Given I am on the forms search page
    Then I should not see "Advanced Search"
    And I should not see "Busque en español"

  Scenario: Switching to web search
    Given I am on the forms home page
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the forms search page
    When I follow "Web"
    Then I should be on the search page
    And I should see 10 search results

  Scenario: Switching to image search
    Given I am on the forms home page
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the forms search page
    When I follow "Images" in the search navigation
    Then I should be on the image search page
    And I should see 30 image results

  Scenario: Switching to Forms search from web or image search
    Given I am on the homepage
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the search page
    When I follow "Forms" in the search navigation
    Then I should be on the forms search page
    And I should see 10 search results

    When I follow "Images" in the search navigation
    Then I should be on the image search page
    When I follow "Forms" in the search navigation
    Then I should be on the forms search page
    And I should see 10 search results

  Scenario: Viewing Top Forms on Forms Landing Page
    Given the following Top Forms exist:
    | name            | url                 | column_number | sort_order  |
    | Column 1        |                     | 1             | 1           |
    | Link 1.1        | http://link11.com   | 1             | 10          |
    | Link 1.2        | http://link12.com   | 1             | 20          |
    | Column 3        |                     | 3             | 1           |
    And I am on the forms home page
    Then I should see "Column 1" within "#top-forms-column-1"
    And I should see "Link 1.1" within "#top-forms-column-1"
    And I should see "Link 1.2" within "#top-forms-column-1"
    And I should see "Column 3" within "#top-forms-column-3"
