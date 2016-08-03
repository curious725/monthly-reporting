App.Helpers.extractObject = function( data, the_object ) {
  var result = {};
  if (_.isObject(data[the_object])) {
    result = data[the_object];
  }

  return result;
};
