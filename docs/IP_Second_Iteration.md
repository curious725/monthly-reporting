#   Second Iteration Implementation Proposal

##  Roles
The application should consider the following roles:
  - administrator,
  - manager,
  - member,
  - guest.

### Administrator Role
User with the **administrator** role has the following privileges:
  - to create teams;
  - to remove _empty_ teams;
  - to add users to teams;
  - to remove users from teams;
  - add and remove holidays.

**NOTE**:
  It seems that all the privileges from the list above are
  to be determined on _position_ basis, not a _team_ role one.


### Manager Role
User with the **manager** role has the following privileges:
  - to approve vacation requests from users with a **member** role;
  - to decline vacation requests from users with a **member** role.

**Important**:
  The user with a role in subject should not approve vacation
  requests from team mate managers.


### Member Role
User with the **member** role has the following privileges:
  - to request a vacation;
  - to cancel own vacation requests; [TODO: state all situations when it is possible]



##  User Interface
The application has the following information representation pages
paired as a menu item name and a respecting URI:
  - Dashboard,  [#/dashboard]
  - Teams,      [#/teams]
  - Vacation,   [#/vacation_requests]
  - Holiday,    [#/holidays]
  - Sign in,    [users/sign_in]


### Dashboard
The page has the following separate sections:
  - Requests,
  - Pending Approval Requests,
  - Vacations Time Table.

The page also provides a control for selecting teams to see in
the **Vacations Time Table** section.

#### Requests
The section represents a table with user's vacation requests that are to be approved
by team mates with the **manager** role.

The table has the following columns:
  - Start date;
  - End date;
  - Type;
  - Operations.

The following columns are to be added:
  - Duration.

#### Pending Approval Requests
The section represents a table with user's vacation requests that are to be approved
by team mates with the **manager** role.

The table has the following columns:
  - Start date;
  - End date;
  - Type;
  - Available Days;
  - User;
  - Operations.

The following columns are to be added:
  - Duration.
