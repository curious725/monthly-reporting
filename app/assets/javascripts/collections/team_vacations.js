App.Collections.TeamVacations = Backbone.Collection.extend({
  initialize: function( options ) {
    this.url = function() {
      return '/teams/' + options.team_id.toString() + '/vacations';
    };
  }
});
