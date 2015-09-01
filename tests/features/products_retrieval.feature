Feature: Retrieve products
  Should be able to retrieve products

  Scenario: Get all products
    And I have an authentication token
    When I send a products request to the API
    Then the API should respond with a 200 response code
    And the response should contain a collection of products