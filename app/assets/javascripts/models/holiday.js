App.Models.Holiday = Backbone.Model.extend({
  defaults: {
    'description':  '',
    'duration':     1,
    'start':        ''
  },

  validateNewValues: function(attributes) {
    var clone = this.clone();

    clone.set(attributes);
    return clone.validate();
  },

  validation: {
    description: {
      required: true,
      rangeLength: [5, 25]
    },
    duration: {
      required: true,
      range: [1, 5]
    },
    start: {
      required: true,
      length: 10
    },
  }
});
