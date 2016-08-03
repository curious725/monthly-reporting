App.Views.Users = Backbone.View.extend({
  el: 'section',
  template: JST['templates/users'],

  initialize: function(options) {
    this.users = options.users;

    this.$el.html(this.template());
    this.$users = $('.panel-group');
  },

  render: function() {
    this.renderTable();

    return this;
  },

  renderTable: function() {
    this.table = new App.Views.UsersList({
      'users': this.users
    });

    this.table.render();
  }
});
