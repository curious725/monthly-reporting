App.Collections.VacationApprovals = Backbone.Collection.extend({
  url: function () {
    var userID = App.currentUser.get('id').toString();
    return 'users/'+userID+'/vacation_approvals';
  }
});
