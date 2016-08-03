App.Views.Teams = Backbone.View.extend({
  el: 'section',
  template: JST['templates/teams'],

  initialize: function(options) {
    this.roles = options.roles;
    this.teams = options.teams;
    this.users = options.users;

    this.teamViews = [];

    this.listenTo(this.users, 'sync', this.render);

    this.data = {
      highestPrivilege: App.currentUserRoles.highestPrivilege()
    };

    this.prepareAppropriateView();

    this.$el.html(this.template(this.data));
    this.$teams = $('.panel-group');
  },

  prepareAppropriateView: function() {
    this.teamView = App.Views.ReadonlyTeam;
    if (this.data.highestPrivilege === 'admin') {
      this.teamView = App.Views.EditableTeam;
    }
  },

  render: function() {
    if (App.currentUserRoles.highestPrivilege() === App.TeamRoles.admin) {
      this.renderForm();
      this.renderTeams();
      this.listenTo(this.teams, 'sync', this.renderTeams);
    } else {
      this.showError('Access denied');
    }

    return this;
  },

  renderTeams: function() {
    this.$teams.html('');
    this.teams.each(function(team) {
      this.addTeamToView(team);
    }, this);
  },

  renderForm: function() {
    if (this.data.highestPrivilege === 'admin') {
      this.form = new App.Views.TeamForm({'teams': this.teams});
      this.form.render();
    }
  },

  addTeamToView: function(team) {
    panel = $('<div class="panel panel-info">').appendTo(this.$teams);

    teamView = new this.teamView({
      'placeholder': panel,
      'roles': this.roles,
      'team': team,
      'users': this.users
    });

    teamView.render();
    this.teamViews.push(teamView);
  },

  showError: function(message) {
    this.$el.html(JST['templates/alerts/error']({'message':message}));
  }
});
