App.Collections.Teams = Backbone.Collection.extend({
  url: '/teams',
  model: App.Models.Team,

  getTeamsByIDs: function(ids) {
    var result = [];

    result = this.filter(function(team) {
      return _.contains(ids, team.id);
    });

    return result;
  }
});
