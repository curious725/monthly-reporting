App.Views.RequestsToApprove = Backbone.View.extend({
  el: '.requests-to-approve',
  template: JST['templates/requests_to_approve'],

  operationsEvents: function() {
    return {
      'click button[name=accept]': this.onAccept,
      'click button[name=decline]': this.onDecline
    };
  },

  initialize: function(options) {
    this.options = options;
    this.approvalRequests = options.approvalRequests;
    this.availableVacations = options.availableVacations;
    this.listenTo(this.approvalRequests, 'sync', this.update);

    this.onAccept   = _.bind(this.onAccept, this);
    this.onDecline  = _.bind(this.onDecline, this);
    this.durationFormatter = _.bind(this.durationFormatter, this);
    this.availableDaysFormatter  = _.bind(this.availableDaysFormatter, this);
  },

  render: function() {
    if (! this.approvalRequests.isEmpty()) {
      this.$el.html(this.template());
      this.renderRequests();
    }
    return this;
  },

  show: function() {
    this.$el.show();
  },

  hide: function() {
    this.$el.hide();
  },

  update: function() {
    if (this.approvalRequests.length > 0) {
      this.$table.bootstrapTable('load', this.approvalRequests);
    } else {
      this.remove();
    }
  },

  renderRequests: function() {
    this.$table = $(this.$el.selector + ' table');

    this.$table.bootstrapTable({
      data: this.approvalRequests.toJSON(),
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
          field: 'kind',
          title: 'Type',
          align: 'center',
          valign: 'middle',
          sortable: true
      }, {
          title: 'Duration',
          align: 'center',
          valign: 'middle',
          formatter: this.durationFormatter,
      }, {
          title: 'Available Days',
          align: 'center',
          valign: 'middle',
          formatter: this.availableDaysFormatter,
          sortable: true
      }, {
          field: 'first_name',
          title: 'User',
          align: 'center',
          valign: 'middle',
          formatter: this.fullNameFormatter,
          sortable: true
      }, {
          field: 'operations',
          title: 'Operations',
          align: 'center',
          valign: 'middle',
          width: '20%',
          events: this.operationsEvents(),
          formatter: this.managerOperationsFormatter,
          sortable: false
      }],
    });
  },

  onAccept: function(event, value, row, index) {
    var that = this;

    $.get('approval_requests/'+row.id.toString()+'/accept')
      .done(function() {
        that.$table.bootstrapTable('remove', {field:'id', values: [row.id]});
        that.approvalRequests.fetch();
      })
      .fail(function(response) {
        that.showError(response);
      });
  },

  onDecline: function(event, value, row, index) {
    var that = this;

    $.get('approval_requests/'+row.id.toString()+'/decline')
      .done(function() {
        that.$table.bootstrapTable('remove', {field:'id', values: [row.id]});
        that.approvalRequests.fetch();
      })
      .fail(function(response) {
        that.showError(response);
      });
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

  availableDaysFormatter: function (value, row, index) {
    var result = 0;

    result = this.availableVacations
      .findWhere({'user_id':row.user_id, 'kind':row.kind})
      .get('available_days');

    return Math.floor(result);
  },

  fullNameFormatter: function(value, row, index) {
    var result = row.first_name;

    if (!_.isEmpty(row.last_name)) {
      result+=' '+row.last_name;
    }

    return result;
  },

  managerOperationsFormatter: function() {
    return JST['templates/approval_request_manager_operations']();
  },
  showError: function(response) {
    var message = 'ERROR ' + response.status.toString(),
        suggestion = '\n\nThere is possibility that you work with outdated data.\nPage refresh may be helpful.';

    if (response.status === 403) {
      message = 'ERROR: You are not allowed to do this action.';
      suggestion = '\n\nThere is possibility that you lost some priviliges.';
    } else if (response.status === 404) {
      message = 'ERROR: Vacation request is not found on server.';
    } else if (response.status === 409) {
      message = 'ERROR: Vacation request state conflicts with the action.';
    }

    message += suggestion;
    alert(message);
  }
});
