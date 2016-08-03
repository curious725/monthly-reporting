App.Collections.VacationRequests = Backbone.Collection.extend({
  url: '/vacation_requests',
  model: App.Models.VacationRequest,
});
