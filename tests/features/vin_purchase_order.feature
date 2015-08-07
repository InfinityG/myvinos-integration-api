Feature: Create VINOs purchase order
  Should be able to create a VINOs purchase order

  Scenario: Create a VINOs purchase order
    And I have an authentication token
    And I have selected a VINOs top-up product
    When I send the order request to the API
    Then the API should respond with a 200 response code
    And the response should contain a checkout id