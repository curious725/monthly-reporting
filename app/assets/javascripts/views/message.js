App.Views.Message = Backbone.View.extend({
  messageTypes: {
    error: 'error'
  },

  events: {
    'click .alert button.close': 'onClose'
  },

  initialize: function(options) {
    this.message = options.message;
    if (options.messageType === this.messageTypes.error) {
      this.template = JST['templates/alerts/error'];
    }
  },

  render: function() {
    $('section').html(this.template({'message':this.message}));
    return this;
  },

  onClose: function() {
    this.remove();
  }
});
