App.Models.Team = Backbone.Model.extend({
  urlRoot: '/teams',
  defaults: {
    'name': '',
  },

  // Get list of users assigned to the team.
  // The following BB collections instances are expected as input data:
  //  - App.Collections.Roles
  //  - App.Collections.Users
  // Returns array of App.Models.User
  getMembers: function(roles, users) {
    var userIDs = _.chain(roles.where({'team_id':this.get('id')}))
          .map(function(role) {
            return role.attributes;
          })
          .pluck('user_id')
          .unique()
          .value(),
        result = users.filter(function(user) {
          return _.contains(userIDs, user.get('id'));
        });

    return result;
  },

  validation: {
    name: {
      required: true,
      rangeLength: [3, 80]
    },
  }
});
