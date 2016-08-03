// Returns array of date strings formatted as 'YYYY-MM-DD'.
App.Helpers.arrayOfDates = function(start, duration) {
  var count;
  var dateRegExMatcher = /^(19|20)\d\d[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])$/,
      isValidDate = false,
      result = [];

  isValidDate = _.isString(start) && dateRegExMatcher.test(start);
  if (!isValidDate) {
    return result;
  }

  result = _.chain(_.range(duration)).map(function(count) {
    return moment(start, 'YYYY-MM-DD').add(count,'days').format('YYYY-MM-DD');
  }).value();

  return result;
};
