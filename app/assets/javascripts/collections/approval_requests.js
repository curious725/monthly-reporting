App.Collections.ApprovalRequests = Backbone.Collection.extend({
  model: App.Models.ApprovalRequest,
  url: function () {
    var userID = App.currentUser.get('id').toString();
    return 'users/'+userID+'/approval_requests';
  }
});
