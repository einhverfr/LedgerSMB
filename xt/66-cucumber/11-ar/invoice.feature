@weasel
Feature: AR transaction document handling
  As a LedgerSMB user, I want to be able to create transactions,
  save them and post them, with or without separation of duties
  and search for them.


Scenario: Creation of a new sales invoice
   Given a standard test company
# Should have been: And a logged in sales user
     And a customer named "Customer 1"
     And a service "s1"
     And a part "p1"
     And a logged in admin
    When I open the sales invoice entry screen
    Then I expect to see an invoice with 1 empty line
    When I select customer "Customer 1"
     And I select part "p1" on the empty line
    Then I expect to see an invoice with these lines:
      | Item | Number | Description | Qty | Unit | Price | %    | TaxForm |
      | 1    | p1     | p1          | 0   |      |  0.00 |    0 |         |
     And I expect to see an invoice with these document properties:
      | property        | value      |
      | Invoice Created | @today@    |
      | Due Date        | @today@    |
      | Order Number    |            |
      | PO Number       |            |
      | Invoice Number  |            |
      | Description     |            |
      | Currency        | USD        |
      | Shipping Point  |            |
      | Ship via        |            |
      | Notes           |            |
      | Internal Notes  |            |
