App.Views.VacationRequestsList = Backbone.View.extend({
  el: '.vacation-requests-list',
  template: JST['templates/vacation_requests_list'],

  operationsEvents: function() {
    return {
      'click button[name=cancel]':  this.onCancel,
      'click button[name=finish]':  this.onFinish,
      'click button[name=start]':   this.onStart
    };
  },

  initialize: function(options) {
    this.options = options;
    this.collection = options.vacationRequests;
    this.availableVacations = options.availableVacations;
    this.teamMates = options.teamMates;
    this.vacationApprovals = options.vacationApprovals;

    this.listenTo(this.collection, 'sync',  this.renderTable);

    this.onCancel = _.bind(this.onCancel, this);
    this.onFinish = _.bind(this.onFinish, this);
    this.onStart  = _.bind(this.onStart, this);
    this.approversFormatter = _.bind(this.approversFormatter, this);
    this.durationFormatter = _.bind(this.durationFormatter, this);
  },

  render: function() {
    this.$el.html(this.template());

    this.$table = this.$('table.vacation-requests');

    this.renderTable();

    return this;
  },

  renderTable: function() {
    this.$table.bootstrapTable('destroy');
    this.$table.bootstrapTable({
      search: true,
      data: this.collection.toJSON(),
      columns: [{
          field: 'start_date',
          title: 'Start date',
          valign: 'middle',
          sortable: true
      }, {
          field: 'end_date',
          title: 'End date',
          valign: 'middle',
          sortable: true
      }, {
          title: 'Duration',
          align: 'center',
          valign: 'middle',
          formatter: this.durationFormatter,
      }, {
          field: 'kind',
          title: 'Type',
          align: 'center',
          valign: 'middle',
          sortable: true
      }, {
          field: 'status',
          title: 'Status',
          align: 'center',
          valign: 'middle',
          sortable: true
      }, {
          title: 'Approvers',
          align: 'center',
          valign: 'middle',
          formatter: this.approversFormatter,
      }, {
          field: 'operations',
          title: 'Operations',
          align: 'center',
          events: this.operationsEvents(),
          formatter: this.ownerOperationsFormatter,
          width: '15%',
          sortable: false
      }],
    });
  },

  onCancel: function(event, value, row, index) {
    var that = this;

    $.get('vacation_requests/'+row.id.toString()+'/cancel')
      .done(function() {
        // TODO: implement notification, if needed
        // Trigger table update
        that.collection.fetch();
      })
      .fail(function(response) {
        // TODO: implement notification
        console.error('FAIL');
      });
  },

  onFinish: function(event, value, row, index) {
    var that = this;

    $.get('vacation_requests/'+row.id.toString()+'/finish')
      .done(function() {
        // TODO: trigger new vacation request from to refresh available days in badges
        // TODO: implement notification, if needed
        // Trigger table update
        that.collection.fetch();
        that.availableVacations.fetch();
      })
      .fail(function(response) {
        // TODO: implement notification
        console.error('FAIL');
        console.error(response.responseText);
      });
  },

  onStart: function(event, value, row, index) {
    var that = this;

    $.get('vacation_requests/'+row.id.toString()+'/start')
      .done(function() {
        // TODO: implement notification, if needed
        // Trigger table update
        that.collection.fetch();
      })
      .fail(function(response) {
        // TODO: implement notification
        console.error('FAIL');
        console.error(response.responseText);
      });
  },

  approversFormatter: function(value, row, index) {
    var approver = null,
        teamMates = this.teamMates,
        vacationId = row.id;

    approvers = this.vacationApprovals
      .filter(function(o) {
        return o.get('vacation_request_id') === vacationId;
      })
      .map(function(o) {
        approver = teamMates.findWhere({'id': o.get('manager_id')});

        return _.isUndefined(approver) ? '[hidden]' : approver.composeFullName();
      });

    return approvers.join(', ');
  },

  durationFormatter: function(value, row, index) {
      var duration,
          vacation = new App.Models.VacationRequest();

      vacation.set('kind', row.kind);
      vacation.set('start_date', row.start_date);
      vacation.set('end_date', row.end_date);

      duration = vacation.calculateDuration(this.options.holidays);

      return duration;
  },

  ownerOperationsFormatter: function(value, row, index) {
    var buttons = [],
        canBeSetToCancelled = false,
        canBeSetToInprogress = false,
        canBeSetToUsed = false;

    canBeSetToCancelled   = (row.status === App.Vacation.statuses.requested || row.status === App.Vacation.statuses.accepted);
    canBeSetToInprogress  = (row.status === App.Vacation.statuses.accepted);
    canBeSetToUsed        = (row.status === App.Vacation.statuses.inprogress);

    if (canBeSetToCancelled) {
      buttons.push(JST['templates/vacation_operations/cancelled']());
    }

    if (canBeSetToInprogress) {
      buttons.push(JST['templates/vacation_operations/inprogress']());
    }

    if (canBeSetToUsed) {
      buttons.push(JST['templates/vacation_operations/used']());
    }

    return buttons.join('&nbsp;');
  }
});
