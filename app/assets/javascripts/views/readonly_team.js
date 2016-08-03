App.Views.ReadonlyTeam = App.Views.Team.extend({
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
