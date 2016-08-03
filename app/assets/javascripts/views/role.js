App.Views.Role = Backbone.View.extend({
  tagName: 'label',
  className: 'btn btn-default',
  template: JST['templates/role'],

  initialize: function(options) {
    this.userID = options.userID;
    this.roleName = options.roleName;
  },

  render: function() {
    var html = this.template({
      'roleName': this.roleName,
      'userID': this.userID,
    });

    this.$el.html(html);
    this.$input = this.$('input');
    return this;
  },

  activate: function() {
    this.$el.addClass('active');
  },

  check: function() {
    this.$input.attr('checked', 'checked');
  },

  onDestroy: function(model) {
    this.roles.remove(model);
    this.$currentRoleButton.parent().removeClass('active');
  },

  onError: function(model, response, options) {
    var message = _.chain(response.responseJSON.errors)
      .map(function(error) {
        return error;
      })
      .join('\n')
      .value();

    alert(message);
  },

  onSuccess: function(model) {
    console.log('onSuccess');
    this.roles.add(model);
    this.$currentRoleButton.parent().addClass('active');
  }
});
