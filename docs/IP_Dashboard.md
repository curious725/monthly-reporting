#   Dashboard

This document provides general description and implementation details for
the Dashboard page.


##  Description
Dashboard page provides general information regarding vacations in scope of
the whole team.

User is able to select a team and see the following information:
  - personal vacation requests
  - time table with vacations of all users in selected team

If user appears to be a `manager` of the selected team, then information
about all team members' vacation requests is provided in addition to personal
requests. So that the following information is provided:
  - personal vacation requests
  - vacation requests of all team members
  - time table with vacations of all users in selected team


##  Implementation

The application that serves the page should be divided into the following parts:
  1. `App.Views.Dashboard`, main application, the master one.
  2. `App.Views.ApprovalRequests`, application for serving both, *personal vacation requests* and *team members' vacation requests*, as a slave.
  4. `App.Views.TimeTables`, application for serving *vacations time table*, as a slave.

Each application has its own view, template, and collection of data models.


### Main application
The main application should be accessed from the `/#/dashboard` URI
as part of the browser URL address.

#### Prerequisites:
The application needs the following information:
  - *user team roles*, to determine which slave application to be activated
  - *list of teams*, to populate HTML `select` control with list of teams
    in which the user has a membership.

#### Implementation Proposal
The following should be implemented within Backbone application:

1. Add models to provide information about current user, such as user's team roles.
  - `App.Models.CurrentUser`, to provide info about the user
  - `App.Models.CurrentUserRoles`, to provide info about team roles of the user.

2. Add `App.Views.Dashboard` with the following functions:
  - use `App.Collections.Teams` to get list of all teams from the server
  - use `App.Views.ApprovalRequests` to render user's approval requests
  - use `App.Views.ApprovalRequests` to render all team members' approval requests
    that should be accepted or rejected by current user as a manager
  - use `App.Views.TimeTables` to render time table.

The following should be implemented within Rails application:

1. Add `UsersController` controller to provide user related information:
  - add `users#index` that responses with `{current_user, current_user_roles, users}` hash
  - update routes to dispatch `users#index`.


##  Questions
No questions.

##  Estimations
The following table represents approximations on time needed for implementation:

| Feature                       | Planned hours | Actual hours  | Status      |
| :--------------------------   | :-----------: | :-----------: | :---------- |
| `App.Views.Dashboard`         | 8             |  6            | *in progress* |
| `App.Models.CurrentUser`      | 8             |  1            | **done**    |
| `App.Models.CurrentUserRoles` | 8             |  1            | **done**    |
| `App.Views.ApprovalRequests`  | 8             |  6            | *in progress* |
| `App.Views.TimeTables`        | 32            |  40           | *in progress* |
| `UsersController`             | 4             |  2            | **done**    |
