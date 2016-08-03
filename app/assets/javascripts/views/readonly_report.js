App.Views.ReadonlyReport = App.Views.Report.extend({
  events: {
    'click button[name=hide]': 'onClickHide',
    'click button[name=show]': 'onClickShow',
  },

  render: function() {
    this.renderContainer();
    this.renderTable();

    return this;
  }
});
