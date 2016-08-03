App.Views.VacationRequest = Backbone.View.extend({
  tagName: 'tr',
  template: JST['templates/vacation_request'],

  initialize: function() {
    this.attributes = {
      start:  this.model.get('start_date'),
      finish: this.model.get('end_date'),
      status: this.model.get('status'),
      ref:    '#/vacation_request/' + this.model.get('id').toString()
    };
  },

  render: function() {
    var html = this.template(this.attributes);
    this.$el.html(html);
    return this;
  },
});
