App.Views.TimeTableByDay = Backbone.View.extend({
  template: JST['templates/time_table_by_day'],

  initialize: function(options) {
    var that = this;

    this.el = options.el;
    this.team = options.team;

    this.holidays   = options.holidays;
    this.members    = new App.Collections.TeamMembers(this.team.get('id'));
    this.vacations  = new App.Collections.TeamVacations({team_id: this.team.get('id')});

    this.cellWidth  = 20;
    this.dateRange = {
      begin:  options.from,
      end:    options.to,
    };

    this.render();
    this.$table = this.$('.time-table-by-day');

    this.listenTo(this.members,   'sync', this.renderMembersTable);
    this.listenTo(this.vacations, 'sync', this.renderVacationsTable);

    // TODO: extract lines below into router
    this.members.fetch({
      success: function() {
        that.vacations.fetch();
      }
    });
  },

  render: function() {
    this.$el.html(this.template());
    return this;
  },

  update: function(dateRange) {
    this.$table.empty();
    this.dateRange = dateRange;
    this.renderVacationsTable();
    return this;
  },

  renderMembersTable: function() {
    var $list = this.$('.members tbody');
    $list.append('<tr><td><strong>'+this.team.get('name')+'</strong></td></tr>');
    $list.append('<tr><td>&nbsp;</td></tr>');
    this.members.each(function(model) {
      $list.append('<tr><td class="member">'+ model.composeFullName() +'</td></tr>');
    });
  },

  renderVacationsTable: function() {
    this.drawMonths();
    this.drawDays();
    this.drawEmptyTable();
    this.markHolidays();
    this.markVacations();
    return this;
  },

  drawMonths: function() {
    var $td = null,
        date = null,
        cellCounter = 0,
        monthFormat = "MMM (YYYY)",
        cols = this.getNumberOfDays(),
        month = moment(this.dateRange.begin).format(monthFormat);

    this.$table.css('width', this.calculateTableWidth());

    var $tr = $('<tr>').appendTo(this.$table);
    $tr.addClass('head');

    for (var col = 0; col < cols; col++) {
      date = moment(this.dateRange.begin).add(col,'days');
      if (date.format(monthFormat) !== month) {
        $td = $('<td>').appendTo($tr);
        $td.attr('colspan', cellCounter);
        $td.text(month);
        month = date.format(monthFormat);
        cellCounter = 0;
      }
      cellCounter++;
    }

    if (cellCounter > 0) {
        $td = $('<td>').appendTo($tr);
        $td.attr('colspan', cellCounter);
        $td.text(month);
    }
  },

  drawDays: function() {
    var $td = null,
        cols = this.getNumberOfDays(),
        beginDate = this.dateRange.begin;

    var $tr = $('<tr>').appendTo(this.$table);
    $tr.addClass('head');

    for (var col = 0; col < cols; col++) {
      $td = $('<td>').appendTo($tr)
        .text(moment(beginDate).add(col,'days').format('D'));
    }
  },

  drawEmptyTable: function() {
    var $tr = null,
        $td = null,
        date = null,
        cols = this.getNumberOfDays();

    this.members.each( function(user) {
      $tr = $('<tr>').appendTo(this.$table);
      for (var col = 0; col < cols; col++) {
        date = moment(this.dateRange.begin).add(col,'days');
        $td = $('<td>').appendTo($tr)
          .attr('id', this.composeCellID(this.team.get('id'), user.id, date));

        if (App.Helpers.isWeekend(date.toDate())) {
          $td.addClass('weekend');
        }
      }
    }, this);
  },

  markHolidays: function() {
    this.holidays.each(function(holiday) {
      this.markHoliday(holiday);
    }, this);
  },

  markHoliday: function(holiday) {
    var date = null,
        duration =  holiday.get('duration'),
        beginDate = moment(holiday.get('start'));

    this.members.each(function(member) {
      for (date = beginDate.clone(); date < moment(beginDate).add(duration, 'days'); date.add(1, 'day')) {
        selector = '#'+ this.composeCellID(this.team.get('id'), member.get('id'), date);
        $(selector).addClass('holiday');
        $(selector).attr('title', holiday.get('description'));
        $(selector).html('<span class="glyphicon glyphicon-asterisk"></span>');
      }
    }, this);
  },

  markVacations: function() {
    this.vacations.each(function(vacation) {
      this.markVacation(vacation);
    }, this);
  },

  markVacation: function(vacation) {
    var date = null,
        endDate = null,
        weekRange = null,
        weekendCounter = 0,
        vacationRange = null,
        duration = 1,
        beginDate = moment(vacation.get('start_date'));

    duration = new App.Models.VacationRequest(vacation.attributes).calculateDuration(this.holidays);

    for (date = beginDate.clone(); date < moment(beginDate).add(duration, 'days'); date.add(1, 'day')) {
      if (App.Helpers.isWeekend(date.toDate()) || App.Helpers.isHoliday(date, this.holidays.arrayOfDates())) {
        duration++;
        continue;
      }
      selector = '#'+ this.composeCellID(this.team.get('id'), vacation.get('user_id'), date);
      $(selector).addClass(vacation.get('kind'));
      $(selector).addClass(vacation.get('status'));
    }
  },

  // ***************************** Helpers *************************************
  calculateTableWidth: function() {
    return this.getNumberOfDays() * this.cellWidth;
  },

  getNumberOfDays: function() {
    var range = moment.range(this.dateRange.begin,
                             this.dateRange.end);

    return range.diff('days') + 1;
  },

  composeCellID: function(teamId, userId, date) {
    return [teamId, userId, date.format('YY-MM-DD')].join('-');
  }
});
