App.Views.EditableTeam = App.Views.Team.extend({
  events: {
    'change input[name=roles]': 'onRoleToggle',
    'click button[name=rename]': 'onClickRename',
    'click button[name=delete]': 'onClickDelete',
    'click button[name=edit]': 'onClickEdit',
    'click button[name=done]': 'onClickDone',
    'click button[name=hide]': 'onClickHide',
    'click button[name=show]': 'onClickShow',

    'click button[name=update]': 'onClickUpdate',
  },

  render: function() {
    this.renderContainer();
    this.renderTable(this.members);

    if (this.members.length > 0) {
      this.buttons.remove.hide();
    }

    this.listenTo(this.team, 'error', this.onTeamError);
    this.listenTo(this.team, 'invalid', this.onTeamInvalid);

    this.$currentRoleButton = null;
    return this;
  },

  addButtons: function() {
    this.buttons = {
      'remove': $(JST['templates/buttons/remove']()),
      'rename': $(JST['templates/buttons/rename']({'teamName':this.team.get('name')})).popover({html:true}),
      'edit': $(JST['templates/buttons/edit']()),
      'done': $(JST['templates/buttons/done']()).hide(),
      'hide': $(JST['templates/buttons/hide']()),
      'show': $(JST['templates/buttons/show']()),
    };

    _.each(this.buttons, function(button) {
      button.appendTo(this.$buttonGroup);
    }, this);
  },

  rolesFormatter: function(value, row, index) {},

  editableRolesFormatter: function(value, row, index) {
    var user = new App.Models.User().set(row),
        roles = this.getArrayOfRoles(user),
        $rolesButtonGroup = $('<div class="btn-group">');

    _.each(App.TeamRoles, function(role) {
      var roleView = new App.Views.Role({'roles':this.roles,'userID':user.get('id'),'roleName':role});

      roleView.render();
      roleView.$el.appendTo($rolesButtonGroup);
      if (_.contains(roles, role)) {
        roleView.activate();
        roleView.check();
      }
    }, this);

    $rolesButtonGroup.attr('data-toggle', 'buttons');

    return $rolesButtonGroup[0].outerHTML;
  },

  onClickEdit: function(event) {
    this.mode = App.TeamView.modes.editable;
    this.renderTable();
    this.$placeholder.show();
    this.hideAllButtons();
    this.buttons.done.show();
  },

  onClickDone: function(event) {
    this.prepareMembers();
    this.mode = App.TeamView.modes.readonly;
    this.renderTable();
    this.showAllButtons();
    this.buttons.done.hide();
    this.buttons.show.hide();

  },

  onClickRename: function(event) {
    this.buttons.rename.popover('toggle');
  },

  onClickDelete: function(event) {
    this.listenToOnce(this.team, 'sync', this.onTeamDestroySuccess);
    this.team.destroy();
  },

  onClickUpdate: function(event) {
    var value = this.$('input[name=team-name]').val().trim(),
        errorMessage = this.team.preValidate('name', value),
        isNameChanged = false;

    isNameChanged = this.team.get('name') !== value;
    hasErrors = _.isString(errorMessage) && errorMessage.length > 0;

    if (hasErrors) {
      alert(errorMessage);
    } else if (isNameChanged) {
      this.team.set('name', value);
      this.listenToOnce(this.team, 'sync', this.onTeamUpdateSuccess);
      this.team.save();
    }

    this.buttons.rename.popover('hide');
  },

  onRoleDestroy: function(model) {
    this.roles.remove(model);
    this.$currentRoleButton.parent().removeClass('active');
  },

  onRoleError: function(model, response, options) {
    if (response.statusText === 'Forbidden') {
      alert('You are not allowed to operate on roles');
    }
  },

  onRoleSuccess: function(model) {
    this.roles.add(model);
    this.$currentRoleButton.parent().addClass('active');
  },

  onTeamError: function(model, response, options) {
    var message = '';

    if (response.statusText === 'Forbidden') {
      message = 'You are not allowed to operate on teams';

    } else if (!_.isUndefined(response.responseJSON.errors)) {
      message = _.chain(response.responseJSON.errors)
        .map(function(error) {
          return error;
        })
        .join('\n')
        .value();
    }

    if (message !== '') {
      alert(message);
    }
  },

  onTeamDestroySuccess: function(model) {
    this.remove();
  },

  onTeamInvalid: function(model) {
    var message = '';

    message = _.chain(model.validationError)
      .map(function(error) {
        return error;
      })
      .join('\n')
      .value();

    if (message !== '') {
      alert(message);
    }
  },

  onTeamUpdateSuccess: function(model) {
  },

  onRoleToggle: function(event) {
    var $input = $(event.target),
        role = new App.Models.Role(),
        toBeAdded = $input.prop('checked'),
        userID = $input.data('userId');

    this.$currentRoleButton = $input;
    if (toBeAdded) {
      role.set('role', $input.val());
      role.set('user_id', userID);
      role.set('team_id', this.team.get('id'));

      this.listenToOnce(role, 'error', this.onRoleError);
      this.listenToOnce(role, 'sync', this.onRoleSuccess);

      role.save();
      this.$currentRoleButton.parent().removeClass('active');

    } else {
      role = this.roles.findWhere({
        'role': $input.val(),
        'user_id': userID,
        'team_id': this.team.get('id'),
      });

      this.listenToOnce(role, 'destroy', this.onRoleDestroy);
      this.$currentRoleButton.parent().addClass('active');
      role.destroy();
    }
  }
});
