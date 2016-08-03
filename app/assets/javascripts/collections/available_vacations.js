App.Collections.AvailableVacations = Backbone.Collection.extend({
  url: '/available_vacations',

  availableDaysOfType: function(vacationType) {
    return this.findWhere({'kind':vacationType}).get('available_days');
  }
});
