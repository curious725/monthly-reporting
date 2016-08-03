App.Collections.PersonalVacationRequests = Backbone.Collection.extend({
  model: App.Models.VacationRequest,
  url: function() {
    var userID = App.currentUser.get('id');
    return '/users/' + userID.toString() + '/requested_vacations/';
  }
});
