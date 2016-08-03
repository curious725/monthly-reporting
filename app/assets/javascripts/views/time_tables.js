App.Views.TimeTables = Backbone.View.extend({
  el: '.time-table-content',
  template: JST['templates/time_tables'],

  events: {
    'change input[name=from]':        'onFromChange',
    'change input[name=to]':          'onToChange',
    'change select[name=view-type]':  'onViewType'
  },

  initialize: function(options) {
    this.attributes = {};
    this.holidays = options.holidays;
    this.timeTableDateRange = {};

    this.teams = options.teams;
    this.timeTableViews = [];

    this.setDefaultViewType();
    this.setDefaultDateRange();

    this.render();
  },

  render: function() {
    this.renderTemplate(this.attributes);
    App.Helpers.assignDatePicker($('.input-daterange'));
    this.renderTimeTableLegend();
    this.renderTimeTables();

    return this;
  },

  update: function(teams) {
    this.teams = teams || this.teams;
    this.renderTimeTables();
    return this;
  },

  renderTemplate: function() {
    this.$el.html(this.template(this.attributes));
  },

  renderTimeTableLegend: function() {
    $('.legend').append(JST['templates/time-table-legend']());
  },

  // *************************************************************************
  renderTimeTables: function() {
    var $timeTableContainer = null;
    var selector = '';
    var timeTable = this.getTimeTableType();

    this.$('.time-tables').empty();
    this.destroyTimeTables();

    this.teams.forEach(function(team) {
      selector = 'team'+team.id;
      $timeTableContainer = $('<div>').appendTo('.time-tables')
        .attr('id', selector)
        .addClass('time-table');
      this.timeTableViews.push( new timeTable({
                                  'team': team,
                                  'el': '#'+selector,
                                  'from': this.timeTableDateRange.begin,
                                  'to': this.timeTableDateRange.end,
                                  'holidays': this.holidays
                                }));
    }, this);
  },

  updateTimeTables: function() {
    this.timeTableViews.forEach(function(view) {
      view.update(this.timeTableDateRange);
    }, this);
  },

  destroyTimeTables: function() {
    this.timeTableViews.forEach(function(view) {
      view.remove();
    });
  },

  getTimeTableType: function() {
    return this.viewType === 'day' ? App.Views.TimeTableByDay : App.Views.TimeTableByWeek;
  },

  // *************************************************************************
  onFromChange: function(event) {
    var oldDate = this.timeTableDateRange.begin,
        newDate = moment(event.target.value),
        interval = oldDate.toDate() - newDate.toDate();

    if (interval !== 0) {
      this.timeTableDateRange.begin = moment(event.target.value);
      this.updateTimeTables();
    }
  },

  onToChange: function(event) {
    var oldDate = this.timeTableDateRange.end,
        newDate = moment(event.target.value),
        interval = oldDate.toDate() - newDate.toDate();

    if (interval !== 0) {
      this.timeTableDateRange.end   = moment(event.target.value);
      this.updateTimeTables();
    }
  },

  onViewType: function(event) {
    this.viewType = event.target.value;
    this.attributes.viewType = this.viewType;

    this.update();
  },
  // *************************************************************************

  setDefaultDateRange: function() {
    var now = moment();
    this.timeTableDateRange.begin = moment(now.format('YYYY-MM-DD'));
    this.timeTableDateRange.end   = moment(now.add(3, 'months').format('YYYY-MM-DD'));
    this.attributes.from  = this.timeTableDateRange.begin.format('YYYY-MM-DD');
    this.attributes.to    = this.timeTableDateRange.end.format('YYYY-MM-DD');
  },

  setDefaultViewType: function() {
    this.viewType = 'day';
    this.attributes.viewType = this.viewType;
  }
});
