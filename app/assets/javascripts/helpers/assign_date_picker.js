// Assign Bootstrap DatePicker to Jquery object
// https://bootstrap-datepicker.readthedocs.org
App.Helpers.assignDatePicker = function(container, options) {
  var settings = {
        autoclose: true,
        calendarWeeks: false,
        format: 'yyyy-mm-dd',
        orientation: 'top auto',
        startDate: '2013-09-01',
        endDate: '2050-01-01',
        todayBtn: true,
        todayHighlight: true,
        weekStart: 1,
      };

  _.extend(settings, options);

  container.datepicker(settings);
};
