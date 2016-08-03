App.Views.ReportForm = App.Views.BootstrapModal.extend({
  template: JST['templates/forms/report/form'],

  events: {
    'click button[name=close]': 'onClose',
    'click button[name=save]':  'onSave',
  },

  prepareData: function() {
    this.content = this.template();
    this.buttons = '';
    this.buttons += JST['templates/forms/report/buttons/close']();
    this.buttons += JST['templates/forms/report/buttons/save']();

    this.model = this.options.report;
    this.model.isChanged = false;

    this.collection = this.options.collection;
  },

  addDOMBindings: function() {
    App.Helpers.assignDatePicker(this.$('[name=created_at]'), {
      startDate: '1900-01-01',
      endDate: '2050-01-01',
    });

    //App.Helpers.assignDatePicker(this.$('[name=employment_date]'));
  },

  addListeners: function() {
    this.listenTo(this.model, 'change', this.onChange);
    this.listenTo(this.model, 'error', this.onError);
    this.listenTo(this.model, 'sync', this.onSuccess);
    this.listenTo(this.model, 'invalid', this.onInvalid);
  },

  renderAssistant: function() {
    this.setFormValues();
  },

  getFormValues: function() {
    this.model.set(this.$('[name=body]').name, this.$('[name=body]').value.trim());
    this.model.set(this.$('input[type=text]').name, this.$('input[type=text]').value.trim());
    // _.each(this.$('input[type=text]'), function(input) {
    //   this.model.set(input.name, input.value.trim());
    // }, this);
  },

  setFormValues: function() {
    _.each(this.$('input[type=text]'), function(input) {
      input.value = this.model.get(input.name);
    }, this);
  },

  onClear: function() {
    this.clearModel();
    this.clearForm();
  },

  onSave: function() {
    var isValid = false;

    this.getFormValues();
    isValid = this.model.isValid(true);

    if (isValid && this.model.isChanged) {
      this.model.save();
    } else if (isValid && !this.model.isChanged) {
      this.hide();
    }
  },

  onClose: function(event) {
    this.hide();
  },

  onChange: function(model, options) {
    this.model.isChanged = true;
  },

  onError: function(model, response, options) {
    var message = response.responseJSON.errors.join('\n');

    alert(message);
  },

  onInvalid: function(model, errors, options) {
    var message = _.values(errors).join('\n');

    alert(message);
  },

  onSuccess: function(model, response, options) {
    // Trigger App.Views.UsersList rendering
    this.collection.fetch();
    // Clear model to set it as a new one,
    // and initialize it with form data.
    // Otherwise, the model is initialized with response data and a next save()
    // will emit PUT request (update) instead of POST (create)
    this.clearModel();
    this.hide();
  },

  clearModel: function () {
    this.model.clear({silent:true});
  },

  hide: function() {
    this.$el.modal('hide');
  }
});


// App.Views.ReportForm = Backbone.View.extend({
//   el: '.new-report-form',
//   template: JST['templates/report_form'],

//   events: {
//     'click button[name=clear]':   'onClear',
//     'click button[name=create]':  'onCreate',
//   },

//   initialize: function(options) {
//     this.reports = options.reports;
//     // this.parent = options.parent;
//     this.model = new App.Models.Report();
//     this.model.urlRoot = 'reports';

//     this.listenTo(this.model, 'sync', this.onSuccess);
//     this.listenTo(this.model, 'error', this.onError);
//     this.listenTo(this.model, 'invalid', this.onInvalid);
//   },

//   render: function() {
//     this.$el.html(this.template());
//     return this;
//   },

//   onClear: function() {
//     this.clearModel();
//     this.clearForm();
//   },

//   onCreate: function() {
//     this.model.set('name', $('input[name=new-report-body]').val().trim());
//     this.model.save();
//   },

//   onError: function(model, response, options) {
//     var message = _.chain(response.responseJSON.errors)
//       .map(function(error) {
//         return error;
//       })
//       .join('\n')
//       .value();

//     alert(message);
//   },

//   onInvalid: function(model, response, options) {
//     var message = _.chain(model.validationError)
//       .map(function(error) {
//         return error;
//       })
//       .join('\n')
//       .value();

//     alert(message);
//   },

//   onSuccess: function(model, response, options) {
//     // Trigger App.Views.Teams rendering
//     this.reports.fetch();
//     // Clear model to set it as a new one,
//     // and initialize it with form data.
//     // Otherwise, the model is initialized with response data and a next save()
//     // will emit PUT request (update) instead of POST (create)
//     this.clearModel();
//     this.clearForm();
//   },

//   clearForm: function () {
//     this.$('input[name=new-report-body]').val('');
//   },

//   clearModel: function () {
//     this.model.clear({silent:true});
//   }
// });
