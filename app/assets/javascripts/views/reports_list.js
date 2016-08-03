App.Views.ReportsList = Backbone.View.extend({
  el: '.reports-list',
  template: JST['templates/reports_list'],

  events: {
    'click button[name=add]':  'onClickAdd',
   // 'click button[name=delete]': 'onClickDelete',
  },

  operationsEvents: function() {
    return {
      //'click button[name=invite]':  this.onClickInvite,
      'click button[name=delete]':  this.onClickDelete,
      'click button[name=edit]':    this.onClickEdit,
    };
  },

  initialize: function(options) {
    this.collection = options.reports;

    this.listenTo(this.collection, 'sync',  this.updateTable);

    // this.onClickInvite = _.bind(this.onClickInvite, this);
    this.onClickDelete = _.bind(this.onClickDelete, this);
    this.onClickEdit = _.bind(this.onClickEdit, this);
  },

  render: function() {
    this.$el.html(this.template());

    this.$table = this.$('table.reports');

    this.renderTable();

    return this;
  },

  renderTable: function() {
    this.$table.bootstrapTable({
      search: true,
      toolbar: '.reportsTableToolbar',
      data: this.collection.toJSON(),
      columns: [{
          field: 'body',
          title: 'Report Column',
          valign: 'middle',
          sortable: true,
      }, {
          field: 'created_at',
          title: 'Date of Creation',
          align: 'center',
          valign: 'middle',
          sortable: true
      }, {
          field: 'operations',
          title: 'Operations',
          align: 'center',
          events: this.operationsEvents(),
          formatter: this.operationsFormatter,
          width: '15%',
          sortable: false
      }],
    });
  },

  updateTable: function() {
    this.$table
      .bootstrapTable('load', {
        data: this.collection.toJSON(),
      });
  },

  onClickAdd: function() {
    var report = new App.Models.Report(),
        title = 'Create new report';

    this.processModalForm(report, title);
  },

  onClickEdit: function(event, value, row, index) {
    var report = this.collection.get(row.id),
        title = 'Edit Report Details for ';

    this.processModalForm(report, title);
  },

  processModalForm: function(report, title) {
    var modal = new App.Views.ReportForm({
                      'title': title,
                      'report': report,
                      'collection': this.collection,
                    });

    $('.report-form').html(modal.render().$el);

    $('#theModal').modal();
  },

  // onClickInvite: function(event, value, row, index) {
  //   var that = this;

  //   $.get('/users/'+row.id+'/invite')
  //     .done(function() {
  //       that.showSuccessMessage('Invitation is sent to '+row.email);
  //     })
  //     .fail(function(response) {
  //       that.showErrorMessage('Failed to send invitation to '+row.email);
  //     });
  // },

  getReportDeleteConfirmation: function(report) {
    var message = '';

    message+='You are about to delete this report from DB, for ever.\n';
    //message+='NOTE: All the user related things like vacations and approvals will be deleted as well.';
    return confirm(message);
  },

  // onClickDelete: function(event, value, row, index) {
  //   var confirmed = false,
  //       reportToDelete = this.collection.get(row.id);

  //   confirmed = this.getReportDeleteConfirmation(reportToDelete);
  //   if (confirmed) {
  //     this.listenToOnce(reportToDelete, 'sync', this.onReportDeleteSuccess);
  //     reportToDelete.destroy();
  //   }
  // },

  //from teams//
  onClickDelete: function(event, value, row, index) {
    var reportToDelete = this.collection.get(row.id);
    this.listenToOnce(reportToDelete, 'sync', this.onReportDeleteSuccess);
    reportToDelete.destroy();
  },

  onReportDeleteSuccess: function(model) {
    this.$table.bootstrapTable('remove', {field: 'id', values: [model.get('id')]});
  },

  //end from teams//
  // onReportDeleteSuccess: function(model) {
  //   this.$table.bootstrapTable('remove', {field: 'id', values: [model.get('id')]});
  // },

  showErrorMessage: function(message) {
    this.$('.panel-body').prepend(JST['templates/alerts/error']({'message':message}));
  },

  showSuccessMessage: function(message) {
    this.$('.panel-body').prepend(JST['templates/alerts/success']({'message':message}));
  },

  operationsFormatter: function(value, row, index) {
    var buttons = [],
        canBeInvited = false;

    canBeInvited = (_.isNull(row.invitation_accepted_at));

    if (canBeInvited) {
      buttons.push(JST['templates/operations/reports/invite']());
    }

    buttons.push(JST['templates/operations/reports/edit']());
    buttons.push(JST['templates/operations/reports/delete']());

    return buttons.join('&nbsp;');
  }
});
