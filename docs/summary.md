#   Summary
This document describes state of the application development as of 2015-09-14.


##  Partially Implemented

### Teams
  - CRUD for the teams [`done`]

    User abilities are determined by roles in teams.

    User with a manager role in **any** team is able to CRUD **all** the teams.

    It should be done by admin, not a manager. Admin is to be determined by user's position.

  - Assign users to teams with particular roles [`to be decided`]

### Dashboard
Delegates almost all responsibilities to other parts it consists of.

Just improve HTML control for selecting teams.

#### User Requests
Decide how to improve table.

#### Pending Approval Requests
Decide how to improve table.


### List of Vacations
Improve HTML layout.


### Vacation Request Details
Improve HTML layout.
Fix bugs.


##  Not Implemented
The following described features are not implemented:
  - JS date picker HTML control [`integrated in Holidays`]
  - BB redirection to sign in page, if user is not authenticated
  - Approval Requests, CRUD

    It is considered to implement some functionality on Dashboard, in the tables.

  - Flash messages handling
  - Form validation error messages handling
  - Devise login pages style
