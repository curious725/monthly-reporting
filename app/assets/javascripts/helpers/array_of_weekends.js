// Returns array of date strings formatted as 'YYYY-MM-DD'.
// Each date is a weekend.
App.Helpers.arrayOfWeekends = function(start, duration) {
  var count;
  var date = '',
      dateRegExMatcher = /^(19|20)\d\d[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])$/,
      isValidDate = false,
      result = [];

  isValidDate = (typeof start === 'string') && dateRegExMatcher.test(start);
  if (!isValidDate) {
    return result;
  }

  for (count = 0; count < duration; count++) {
    date = moment(start, 'YYYY-MM-DD').add(count, 'days').format('YYYY-MM-DD');
    if (App.Helpers.isWeekend(date)) {
      result.push(date);
    }
  }

  return result;
};
