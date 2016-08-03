App.Views.Holidays = Backbone.View.extend({
  el: 'section',
  template: JST['templates/holidays'],

  events: {
    'click button[name=add]':  'onAddHoliday',
  },

  initialize: function(options) {
    this.attributes = {
      highestPrivilege: App.currentUserRoles.highestPrivilege()
    };
    this.$el.html(this.template(this.attributes));
    App.Helpers.assignDatePicker($('.input-daterange'));
    this.collection = options.collection;

    this.listenTo(this.collection, 'error', this.showServerErrors);
    this.listenTo(this.collection, 'sync',  this.render);

    this.$description = this.$('.new input[name=description]');
    this.$from = this.$('.new input[name=from]');
    this.$to   = this.$('.new input[name=to]');
  },

  render: function() {
    var $list = this.$('ul').empty();

    this.collection.each(function(model) {
      var item = new App.Views.Holiday({'model': model});
      $list.append(item.render().$el);
    });

    return this;
  },

  fetchFormValues: function() {
    var _description  = this.$description.val().trim(),
        _from         = this.$from.val().trim(),
        _to           = this.$to.val().trim(),
        duration = moment.duration(moment(_to).diff(moment(_from))).days()+1,

        result = {
          description: _description,
          duration: duration,
          start: _from
        };

    return result;
  },

  clearFormValues: function() {
    this.$('.new input[type=text]').val('');
  },

  onAddHoliday: function(event) {
    var that = this,
        model = new App.Models.Holiday(),
        attributes = this.fetchFormValues(),
        errors = model.validateNewValues(attributes);

    if (errors) {
      this.showErrors(errors);
    } else {
      model.set(attributes);
      this.collection.create(model, {
        success: function(model, response) {
          that.clearFormValues();
        }
      });
    }
  },

  showServerErrors: function(model, response) {
    // TODO: show array of errors from response.responseJSON.errors
  },

  showErrors: function(errors) {
    // TODO: show array of errors
  }
});
