App.Views.UsersList = Backbone.View.extend({
  el: '.users-list',
  template: JST['templates/users_list'],

  events: {
    'click button[name=add]':  'onClickAdd',
  },

  operationsEvents: function() {
    return {
      'click button[name=invite]':  this.onClickInvite,
      'click button[name=delete]':  this.onClickDelete,
      'click button[name=edit]':    this.onClickEdit,
    };
  },

  initialize: function(options) {
    this.collection = options.users;

    this.listenTo(this.collection, 'sync',  this.updateTable);

    this.onClickInvite = _.bind(this.onClickInvite, this);
    this.onClickDelete = _.bind(this.onClickDelete, this);
    this.onClickEdit = _.bind(this.onClickEdit, this);
  },

  render: function() {
    this.$el.html(this.template());

    this.$table = this.$('table.users');

    this.renderTable();

    return this;
  },

  renderTable: function() {
    this.$table.bootstrapTable({
      search: true,
      toolbar: '.usersTableToolbar',
      data: this.collection.toJSON(),
      columns: [{
          field: 'first_name',
          title: 'First Name',
          valign: 'middle',
          sortable: true,
      }, {
          field: 'last_name',
          title: 'Last Name',
          valign: 'middle',
          sortable: true
      }, {
          field: 'email',
          title: 'email',
          align: 'center',
          valign: 'middle',
      }, {
          field: 'birth_date',
          title: 'Date of Birth',
          align: 'center',
          valign: 'middle',
          sortable: true
      }, {
          field: 'employment_date',
          title: 'Date of Employment',
          align: 'center',
          valign: 'middle',
          sortable: true
      }, {
          field: 'operations',
          title: 'Operations',
          align: 'center',
          events: this.operationsEvents(),
          formatter: this.operationsFormatter,
          width: '15%',
          sortable: false
      }],
    });
  },

  updateTable: function() {
    this.$table
      .bootstrapTable('load', {
        data: this.collection.toJSON(),
      });
  },

  onClickAdd: function() {
    var user = new App.Models.User(),
        title = 'New User Details';

    this.processModalForm(user, title);
  },

  onClickEdit: function(event, value, row, index) {
    var user = this.collection.get(row.id),
        title = 'Edit User Details for '+user.composeFullName();

    this.processModalForm(user, title);
  },

  processModalForm: function(user, title) {
    var modal = new App.Views.UserForm({
                      'title': title,
                      'user': user,
                      'collection': this.collection,
                    });

    $('.user-form').html(modal.render().$el);

    $('#theModal').modal();
  },

  onClickInvite: function(event, value, row, index) {
    var that = this;

    $.get('/users/'+row.id+'/invite')
      .done(function() {
        that.showSuccessMessage('Invitation is sent to '+row.email);
      })
      .fail(function(response) {
        that.showErrorMessage('Failed to send invitation to '+row.email);
      });
  },

  getUserDeleteConfirmation: function(user) {
    var message = '';

    message+='You are about to delete <'+user.composeFullName()+'> from DB, for ever.\n';
    message+='NOTE: All the user related things like vacations and approvals will be deleted as well.';
    return confirm(message);
  },

  onClickDelete: function(event, value, row, index) {
    var confirmed = false,
        userToDelete = this.collection.get(row.id);

    confirmed = this.getUserDeleteConfirmation(userToDelete);
    if (confirmed) {
      this.listenToOnce(userToDelete, 'sync', this.onUserDeleteSuccess);
      userToDelete.destroy();
    }
  },

  onUserDeleteSuccess: function(model) {
    this.$table.bootstrapTable('remove', {field: 'id', values: [model.get('id')]});
  },

  showErrorMessage: function(message) {
    this.$('.panel-body').prepend(JST['templates/alerts/error']({'message':message}));
  },

  showSuccessMessage: function(message) {
    this.$('.panel-body').prepend(JST['templates/alerts/success']({'message':message}));
  },

  operationsFormatter: function(value, row, index) {
    var buttons = [],
        canBeInvited = false;

    canBeInvited = (_.isNull(row.invitation_accepted_at));

    if (canBeInvited) {
      buttons.push(JST['templates/operations/users/invite']());
    }

    buttons.push(JST['templates/operations/users/edit']());
    buttons.push(JST['templates/operations/users/delete']());

    return buttons.join('&nbsp;');
  }
});
