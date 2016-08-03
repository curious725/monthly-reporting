App.Models.TeamMember = Backbone.Model.extend({
  composeFullName: function() {
    var result = '',
        value = this.get('first_name');

    if (_.isString(value)) {
      result = value.trim();
    }

    value = this.get('last_name');
    if (_.isString(value)) {
      result = result.concat(' ' + value.trim());
    }

    return result;
  }
});
