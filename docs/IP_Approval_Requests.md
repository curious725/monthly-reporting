#   Approval Requests

This document provides general description and implementation details for
the `App.Views.ApprovalRequests` application.


##  Description
The `App.Views.ApprovalRequests` application should provide information regarding
approval requests for vacation requests. This information should be presented
as a list of vacations.

Team member can request a vacation. Any time a vacation request is created
a new approval request should be created. Approval request should be created
right after vacation request is stored in the DB.

Each vacation request should have at least one approval request.

Approval request should be seen by team manager and the user who requested
the vacation.

Manager should be able to accept or reject requests from team members.
It is done by means of approval requests.

Team member should be able to cancel own vacation requests.

All approval requests must be deleted from DB when vacation request is canceled.

Approval request must be deleted from DB when team manager accepts vacation request.

If vacation request has no related approval requests, status of the request
should be set to `accepted`.

##  Implementation

The application should be divided into the following parts:
  1. `App.Views.ApprovalRequests`, a view to represent a *list of vacations*
      that should be accepted or rejected,
      provided by `ApprovalRequests` collection.
  2. `App.Views.ApprovalRequest`, a view to represent a *vacations request*
      provided by `ApprovalRequest` model.
  3. `App.Models.ApprovalRequest`, a model that represents vacation request
      with `requested` status.
  4. `App.Collections.ApprovalRequests`, a collection of `ApprovalRequest` models,
      that forms a *list of vacations*.

The application should be used by the `App.Views.Dashboard`.

The entry point is `App.Views.ApprovalRequests`.

The application should be configurable to accept following options:
  - `{manager_id: managerID}` to provide list of vacation requests
    that should be accepted or rejected by current user
  - `{user_id: [userID}` to provide list of user's vacation requests
    that should be accepted or rejected by team managers.
Only one option should be passed to the constructor. For instance:


### `App.Views.ApprovalRequests`
The `App.Views.ApprovalRequests` view should relay on HTML template
that describes visual representation of data.

#### Prerequisites

The view requires the following view:
  - `App.Views.ApprovalRequest`, to represent a vacation request details

The view requires template to represent the following:
  - list of vacation requests

The view requires the following information:
  - *list of users IDs*, to determine which requests are to be displayed


### `App.Views.ApprovalRequest`
The `App.Views.ApprovalRequest` view should relay on HTML template
that describes visual representation of data.


#### Prerequisites
The view requires template to represent the following:
  - vacation request details with all controls

The view requires the following information:
  - *vacation request details*, to fill template with related data

### Implementation Proposal
The following should be implemented within Backbone application:
  1. Add `App.Models.ApprovalRequest` model to provide information about
    the vacation request with status `requested`.
  2. Add `App.Views.ApprovalRequest` to represent `ApprovalRequest` model.
  3. Add `App.Collections.ApprovalRequests` to provide a list of `ApprovalRequest` models.
  4. Add `App.Views.ApprovalRequests` to represent `ApprovalRequests` collection.

The following should be implemented within Rails application:
  1. Add `VacationRequestsController#requested_vacations(user_id)` method to provide
    vacation requests with the `requested` status.
  2. Update routes to dispatch `requested_vacations/:user_id`.
  3. Create `ApprovalRequestsController` controller to provide data related to approval requests.
  4. Add `ApprovalRequestsController#index` method to provide
    list of vacation requests to be accepted or rejected by the current user.
  5. Update routes to dispatch `approval_requests#index`.

##  Estimations
The following table represents approximations on time needed for implementation:

| Feature                       | Planned hours | Actual hours  | Status      |
| :---------------------------- | :-----------: | :-----------: | :---------- |
| `App.Views.ApprovalRequests`  | 5             | 3             | *in progress* |
| `App.Views.ApprovalRequest`   | 3             |               | *postponed* |
| `VacationRequestsController`  | 1             | 1             | **done**    |
| `ApprovalRequestsController`  | 1             | 2             | **done**    |
