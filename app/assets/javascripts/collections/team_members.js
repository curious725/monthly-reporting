App.Collections.TeamMembers = Backbone.Collection.extend({
  model: App.Models.TeamMember,

  initialize: function( teamID ) {
    this.url = function() {
      return '/teams/' + teamID + '/members';
    };
  }
});
