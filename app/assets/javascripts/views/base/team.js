App.Views.Team = Backbone.View.extend({
  template: JST['templates/team'],

  initialize: function(options) {
    this.roles = options.roles;
    this.role = new App.Models.Role();
    this.team = options.team;
    this.users = options.users;
    this.setElement(options.placeholder);
    this.prepareMembers();
    this.visibleUsers = this.members;
    this.mode = App.TeamView.modes.readonly;

    this.fullNameFormatter = _.bind(this.fullNameFormatter, this);
    this.readonlyRolesFormatter = _.bind(this.readonlyRolesFormatter, this);
    this.editableRolesFormatter = _.bind(this.editableRolesFormatter, this);
    this.rolesFormatter = this.readonlyRolesFormatter;
  },

  renderContainer: function() {
    this.$el.html(this.template({'teamName': this.team.get('name')}));

    this.$placeholder = this.$('.panel-body');
    this.$placeholder.hide();

    this.$buttonGroup = this.$('.buttons');
    this.addButtons();
    this.buttons.hide.hide();
  },

  renderMessage: function(message) {
    this.$placeholder.text(message);
  },

  renderTable: function() {
    var $table = $('<table class="table">');

    this.rolesFormatter = this.readonlyRolesFormatter;
    this.visibleUsers = this.members;

    if (this.mode === App.TeamView.modes.editable) {
      this.rolesFormatter = this.editableRolesFormatter;
      this.visibleUsers = this.users.toJSON();
    }

    if (this.mode === App.TeamView.modes.readonly && this.members.length === 0) {
        this.renderMessage('This team has no members.');
    } else {
      this.$placeholder.html($table);
    }


    $table.bootstrapTable({
      data: this.visibleUsers,
      columns: [{
          title: 'Full Name',
          valign: 'middle',
          formatter: this.fullNameFormatter,
      }, {
          title: 'Roles',
          align: 'center',
          valign: 'middle',
          formatter: this.rolesFormatter,
          width: '30%'
      }],
    });
  },

  addButtons: function() {
    this.buttons = {
      'hide': $(JST['templates/buttons/hide']()),
      'show': $(JST['templates/buttons/show']()),
    };

    _.each(this.buttons, function(button) {
      button.appendTo(this.$buttonGroup);
    }, this);
  },

  hideAllButtons: function() {
    _.each(this.buttons, function(button) {
      button.hide();
    });
  },

  showAllButtons: function() {
    _.each(this.buttons, function(button) {
      button.show();
    });

    if (this.members.length > 0) {
      this.buttons.remove.hide();
    }
  },

  onClickHide: function(event) {
    this.$placeholder.hide();
    this.buttons.hide.hide();
    this.buttons.show.show();
  },

  onClickShow: function(event) {
    this.$placeholder.show();
    this.buttons.hide.show();
    this.buttons.show.hide();
  },

  fullNameFormatter: function(value, row, index) {
    var user = new App.Models.User();

    user.set('first_name', row.first_name);
    user.set('last_name', row.last_name);

    return user.composeFullName();
  },

  rolesFormatter: function() {},

  editableRolesFormatter: function() {},

  readonlyRolesFormatter: function(value, row, index) {
    var user = new App.Models.User().set(row),
        roles = this.getArrayOfRoles(user);

    return roles.join(', ');
  },

  prepareMembers: function() {
    this.members = _.chain(this.team.getMembers(this.roles, this.users))
      .map(function(user) {
        return user.toJSON();
      })
      .value();
  },

  getArrayOfRoles: function(user) {
    var rolesInTeam = user.getRolesInTeam(this.team.get('id'), this.roles);

    return _.chain(rolesInTeam)
      .map(function(role) {
        return role.attributes;
      })
      .pluck('role')
      .value();
  }
});
