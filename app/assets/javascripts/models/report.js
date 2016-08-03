App.Models.Report = Backbone.Model.extend({
  urlRoot: 'reports',
  defaults: {
    'body':'',
    'created_at': moment(new Date()).format('YYYY-MM-DD')
  },

  initialize: function(){
  	//console.log('The report model has been initialized');
  }
});
