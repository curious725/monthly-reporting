App.Views.BootstrapModal = Backbone.View.extend({
  id: 'theModal',
  className: 'modal',

  initialize: function(options) {
    this.options = _.extend({
      'content': 'Put your content here',
      'buttons': this.defaultButtons(),
      'close': true,
      'fade': true,
      'title': 'Modal Dialog',
    }, options);

    this.$el.attr('role', 'dialog');
    if (this.options.fade) {
      this.$el.addClass('fade');
    }

    this.prepareData();
    this.addListeners();
  },

  addDOMBindings: function() {
  },

  addListeners: function() {
  },

  prepareData: function() {
  },

  render: function() {
    var html = '';

    html += this.renderHeader();
    html += this.renderBody();
    html += this.renderFooter();

    container = $('<div>').addClass('modal-dialog')
      .append( $('<div>').addClass('modal-content').html(html) );

    this.$el.html(container[0].outerHTML);

    this.$el.on('hidden.bs.modal', function() {
      this.remove();
    });

    this.addDOMBindings();
    this.renderAssistant();
    return this;
  },

  renderAssistant: function() {
  },

  renderBody: function() {
    var isReadyHTML =  _.isString(this.content),
        isBBView    = !_.isUndefined(this.content.el);

    this.$body = $('<div>').addClass('modal-body');

    if (isReadyHTML) {
      this.$body.html(this.content);
    } else if(isBBView) {
      this.$body.html(this.content.render().$el);
    }

    return this.$body[0].outerHTML;
  },

  renderFooter: function() {
    this.$footer = $('<div>').addClass('modal-footer').html(this.buttons);
    return this.$footer[0].outerHTML;
  },

  renderHeader: function() {
    var node = $('<div>').addClass('modal-header'),
        button = this.defaultCloseControl(),
        title = $('<h4>').html(this.options.title);

    button.appendTo(node);
    title.appendTo(node);
    this.$header = node;

    return node[0].outerHTML;
  },

  defaultCloseControl: function() {
    var button = $('<button>')
          .addClass('close')
          .attr('type','button')
          .attr('arial-label:','Close')
          .attr('data-dismiss','modal'),
        span = $('<span>')
          .html('&times;')
          .attr('aria-hidden','true');

    span.appendTo(button);

    return button;
  },

  defaultButtons: function() {
    var close = $('<button>')
          .addClass('btn btn-default')
          .attr('name','modalClose')
          .html('Close');

    return close[0].outerHTML;
  }
});
