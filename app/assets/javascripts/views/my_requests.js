App.Views.MyRequests = Backbone.View.extend({
  el: '.my-requests',
  template: JST['templates/my_requests'],

  operationsEvents: function() {
    return {
      'click button[name=cancel]': this.onCancel
    };
  },

  onCancel: function(event, value, row, index) {
    var that = this;

    $.get('vacation_requests/'+row.id.toString()+'/cancel')
      .done(function() {
        that.$table.bootstrapTable('remove', {field:'id', values: [row.id]});
      })
      .fail(function(response) {
        var message = 'ERROR' + response.status.toString(),
            suggestion = '\n\nThere is possibility that you work with outdated data.\nPage refresh may be helpful.';

        if (response.status === 404) {
          message = 'ERROR: Vacation request is not found on server.';
        } else if (response.status === 409) {
          message = 'ERROR: Vacation request state conflicts with the action.';
        }

        message += suggestion;
        alert(message);
      });
  },

  initialize: function(options) {
    this.options = options;
    this.requests = options.personalVacationRequests;

    this.listenTo(this.requests, 'sync', this.update);

    this.onCancel = _.bind(this.onCancel, this);
    this.approversFormatter = _.bind(this.approversFormatter, this);
    this.durationFormatter = _.bind(this.durationFormatter, this);
  },

  render: function() {
    if (! this.requests.isEmpty()) {
      this.$el.html(this.template());
      this.renderRequests();
    }
    return this;
  },

  renderRequests: function() {
    this.$table = $(this.$el.selector + ' table');

    this.$table.bootstrapTable({
      data: this.requests.toJSON(),
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
    this.getApprovers();
  },

  getApprovers: function() {
    var approvers = [];

    this.requests.forEach(function(vacation) {
      var collection = new App.Collections.Approvers();
      collection.url = function() { return '/vacation_requests/'+vacation.id+'/approvers'; };
      approvers.push({'collection':collection, 'vacationID': vacation.get('id')});
    });

    approvers.forEach(function(pair) {
      pair.collection.fetch()
        .then(function() {
          var list = [];

          pair.collection.forEach(function(user) {
            var info = '';
            info += user.get('first_name');
            info += ' ';
            info += user.get('last_name');
            list.push(info);
          });
          $('span#'+pair.vacationID).text(list.join(', '));
        });
    });
  },

  approversFormatter: function(value, row, index) {
    return '<span id='+row.id+'></span>';
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
    return JST['templates/approval_request_owner_operations']();
  },

  update: function() {
    if (this.requests.length > 0) {
      this.$table.bootstrapTable('load', this.requests);
    } else {
      this.remove();
    }
  }
});
