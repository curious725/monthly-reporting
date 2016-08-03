App.Models.ApprovalRequest = Backbone.Model.extend({
  defaults: {
    'first_name':'',
    'last_name':'',
    'user_id':0,
    'kind': App.Vacation.types.planned,
    'start_date':'',
    'end_date':''
  },

  get: function(attribute) {
    if (typeof this[attribute] == 'function') {
      return this[attribute]();
    }
    return Backbone.Model.prototype.get.call(this, attribute);
  },

  set: function() {
    var options = {match: true},
        new_keys = [],
        expected_keys = _.keys(this.defaults),
        forbidden_keys = [];

    // Attributes that are not expected by backend in case of a new record,
    // but it is Ok to initialize a model with these attributes.
    expected_keys.push('id');

    if (_.isObject(arguments[0])) {
      options = _.extend(options, arguments[1]);
      new_keys = _.keys(arguments[0]);
      forbidden_keys = _.reject(new_keys, function(key) {
        return _.contains(expected_keys, key);
      });
    } else {
      options = _.extend(options, arguments[2]);
      new_keys = [arguments[0]];
      forbidden_keys = _.reject(new_keys, function(key) {
        return _.contains(expected_keys, key);
      });
    }

    if (options.match === true && !_.isEmpty(forbidden_keys)) {
      message = 'App.Models.ApprovalRequest.set: option {match: true} allows to set only properties from defaults (';
      message +=_.keys(this.defaults)+')';
      message += ', but got (';
      message += forbidden_keys;
      message += ')';
      console.log(message);
      throw new Error(message);
    }

    return Backbone.Model.prototype.set.apply(this, arguments);
  }
});
