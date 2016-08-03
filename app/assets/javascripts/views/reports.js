App.Views.Reports = Backbone.View.extend({
  el: 'section',
  template: JST['templates/reports'],

  initialize: function(options) {
    this.reports = options.reports;

    this.$el.html(this.template());
    this.$reports = $('.panel-group');
  },

  render: function() {
    this.renderTable();

    return this;
  },

  renderTable: function() {
    this.table = new App.Views.ReportsList({
      'reports': this.reports
    });

    this.table.render();
  }
});

// App.Views.Reports = Backbone.View.extend({ф
// 	el: 'section',
// 	template: JST['templates/reports'],

// 	initialize: function(options) {
// 	  this.reports = options.reports;
// 	  // this.options = options || {};
// 	  this.collection = options.reports;

// 	  this.reportViews = [];

//       this.listenTo(this.collection, 'error', this.showServerErrors);
//       this.listenTo(this.collection, 'sync',  this.render);

//       this.prepareAppropriateView();

//       this.$el.html(this.template(this.data));
//       this.$reports = $('.panel-group');

// 	},

//   prepareAppropriateView: function() {
//     this.reportView = App.Views.ReadonlyReport;
//     // if (this.data.highestPrivilege === 'admin') {
//     //   this.teamView = App.Views.EditableTeam;
//     // }
//   },

// 	render: function() {
//     	// $('section').html(this.template({'reports':this.reports}));
//     	// return this;
//     	this.renderForm();
//     	this.renderReports();
//     	this.listenTo(this.reports, 'sync', this.renderReports);
//     	console.log('Rener repports js');
//     	console.log('Rener repports js this: '+this);
    	
//     	return this;
//   	},

//   	renderReports: function() {
//   		this.$reports.html('');
//   		this.reports.each(function(report) {
//   			this.addReportToView(report);
//   		}, this);
//   	},

//   	renderForm: function() {
//     //if (this.data.highestPrivilege === 'admin') {
//       this.form = new App.Views.ReportForm({'reports': this.reports});
//       this.form.render();
//     //}
//     },

//     addReportToView: function(report) {
//       panel = $('<div class="panel panel-info">').appendTo(this.$reports);

//       reportView = new this.reportView({
//       'placeholder': panel,
//       'body': 'Hello'
//     //   // 'team': team,
//     //   // 'users': this.users
//     // });

//     reportView.render();
//     this.reportViews.push(reportView);
//   }

// });
