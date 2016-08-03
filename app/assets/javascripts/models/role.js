App.Models.Role = Backbone.Model.extend({
  urlRoot: '/team_roles',

  defaults: {
    'role':'',
    'user_id':'',
    'team_id':''
  },

  // TODO: add validation
  // validation: {
  //   description: {
  //     required: true,
  //     rangeLength: [5, 25]
  //   },
  //   duration: {
  //     required: true,
  //     range: [1, 5]
  //   },
  //   start: {
  //     required: true,
  //     length: 10
  //   },
  // }
});
