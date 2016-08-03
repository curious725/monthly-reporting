App.Models.User = Backbone.Model.extend({
  urlRoot: 'users',
  defaults: {
    'first_name':'',
    'last_name':'',
    'email':'',
    'position':'',
    'username':'',
    'birth_date':'1990-01-01',
    'employment_date': moment(new Date()).format('YYYY-MM-DD')
  },

  composeFullName: function() {
    var result = '',
        value = this.get('first_name');

    if (_.isString(value)) {
      result = value.trim();
    }

    value = this.get('last_name');
    if (_.isString(value)) {
      result = result.concat(' ' + value.trim());
    }

    return result;
  },

  // Get roles for the user in the provided team.
  // The following input data are expected:
  //  - ID of team, integer
  //  - App.Collections.Roles instance
  // Returns array of App.Models.Role.
  getRolesInTeam: function(teamID, roles) {
    var result = [];

    result = roles.filter(function(role) {
      var isRoleOwner = (role.get('user_id') === this.get('id')),
          isAssignedToTeam = (teamID === role.get('team_id'));

      return (isRoleOwner && isAssignedToTeam);
    }, this);

    return result;
  },

  validation: {
    first_name: {
      required: true,
      rangeLength: [1, 50]
    },
    last_name: {
      required: true,
      rangeLength: [1, 70]
    },
    email: {
      required: true,
      pattern: 'email',
    },
    birth_date: {
      required: true,
      length: 10
    },
    employment_date: {
      required: true,
      length: 10
    },
  }
});
