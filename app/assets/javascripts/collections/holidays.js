App.Collections.Holidays = Backbone.Collection.extend({
  comparator: 'start',
  model: App.Models.Holiday,
  url: '/holidays',

  arrayOfDates: function() {
    var result = [];

    this.each(function(model) {
      result.push(App.Helpers.arrayOfDates(model.get('start'), model.get('duration')));
    });

    return _.flatten(result);
  }
});
