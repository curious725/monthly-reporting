App.Views.Holiday = Backbone.View.extend({
  tagName: 'li',
  className: 'list-group-item',
  template: JST['templates/holiday'],

  events: function() {
    var role = App.currentUserRoles.highestPrivilege(),
        result = {};

    switch (role) {
      case 'admin':
        result = {
          'click button[name=delete]': 'onDelete',
          'dblclick .view': 'enterEditMode',
          'click button[name=update]': 'onUpdate',
          'click button[name=cancel]': 'onCancel'
        };
        break;

      default:
        result = {};
    }

    return result;
  },

  initialize: function(options) {
    this.model = options.model;
    this.attributes = {
      role: App.currentUserRoles.highestPrivilege()
    };
  },

  render: function() {
    this.populateAttributesWithData();

    this.$el.html(this.template(this.attributes));

    return this;
  },

  populateAttributesWithData: function() {
    this.attributes.description = this.model.get('description');
    this.attributes.from = this.model.get('start');
    this.attributes.to = moment(this.model.get('start')).add(this.model.get('duration')-1, 'day').format('YYYY-MM-DD');
    this.attributes.date = moment(this.model.get('start')).format('YYYY, MMMM D, dddd');
    this.attributes.duration = moment.duration(this.model.get('duration'), 'days').humanize();
  },

  enterEditMode: function(event) {
    this.$el.addClass('editing');
    App.Helpers.assignDatePicker($('.input-daterange'));
  },

  exitEditMode: function() {
    this.$el.removeClass('editing');
  },

  onCancel: function(event) {
    this.exitEditMode();
  },

  onUpdate: function(event) {
    this.close();
  },

  fetchFormValues: function() {
    var _description = this.$('input[name=description]').val().trim(),
        _from = this.$('input[name=from]').val().trim(),
        _to   = this.$('input[name=to]').val().trim(),
        duration = App.Helpers.dateRangeDuration(_from, _to),

        result = {
          description: _description,
          duration: duration,
          start: _from
        };

    return result;
  },

  // Close the `"editing"` mode, saving changes.
  close: function() {
    var attributes = this.fetchFormValues(),
        errors = this.model.validateNewValues(attributes);

    if (errors) {
      // TODO: show array of errors
    } else {
      this.model.save(attributes);
      this.exitEditMode();
    }
  },

  onDelete: function() {
    this.model.destroy({
      wait: true,
      // TODO: assign something here
      success: function(model, response) {
      },
      // TODO: assign something here
      error: function(model, response) {
      }
    });

    this.remove();
  }
});
