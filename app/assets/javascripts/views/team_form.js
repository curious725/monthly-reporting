App.Views.TeamForm = Backbone.View.extend({
  el: '.new-team-form',
  template: JST['templates/team_form'],

  events: {
    'click button[name=clear]':   'onClear',
    'click button[name=create]':  'onCreate',
  },

  initialize: function(options) {
    this.teams = options.teams;
    this.parent = options.parent;
    this.model = new App.Models.Team();
    this.model.urlRoot = 'teams';

    this.listenTo(this.model, 'sync', this.onSuccess);
    this.listenTo(this.model, 'error', this.onError);
    this.listenTo(this.model, 'invalid', this.onInvalid);
  },

  render: function() {
    this.$el.html(this.template());
    return this;
  },

  onClear: function() {
    this.clearModel();
    this.clearForm();
  },

  onCreate: function() {
    this.model.set('name', $('input[name=new-team-name]').val().trim());
    this.model.save();
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

  onInvalid: function(model, response, options) {
    var message = _.chain(model.validationError)
      .map(function(error) {
        return error;
      })
      .join('\n')
      .value();

    alert(message);
  },

  onSuccess: function(model, response, options) {
    // Trigger App.Views.Teams rendering
    this.teams.fetch();
    // Clear model to set it as a new one,
    // and initialize it with form data.
    // Otherwise, the model is initialized with response data and a next save()
    // will emit PUT request (update) instead of POST (create)
    this.clearModel();
    this.clearForm();
  },

  clearForm: function () {
    this.$('input[name=new-team-name]').val('');
  },

  clearModel: function () {
    this.model.clear({silent:true});
  }
});
