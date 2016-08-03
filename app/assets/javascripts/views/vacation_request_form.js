App.Views.VacationRequestForm = Backbone.View.extend({
  el: '.new-vacation-request-form',
  template: JST['templates/vacation_request_form'],

  events: {
    'click  button[name=clear]':    'onClear',
    'change input[name=from]':      'onFromChange',
    'click  button[name=request]':  'onRequest',
    'change input[name=to]':        'onToChange',
    'change input:radio[name=vacation-type]': 'onTypeChange'
  },

  initialize: function(options) {
    this.holidays = options.holidays;
    this.vacationRequests = options.vacationRequests;
    this.availableVacations = options.availableVacations;
    this.model = new App.Models.VacationRequest();
    this.model.urlRoot = 'vacation_requests';

    this.listenTo(this.model, 'sync', this.onSuccess);
    this.listenTo(this.model, 'error', this.onError);
    this.listenTo(this.model, 'invalid', this.onInvalid);
    this.listenTo(this.availableVacations, 'sync', this.render);
  },

  render: function() {
    this.$el.html(this.template({'availableVacations':this.availableVacations.models}));
    App.Helpers.assignDatePicker($('.input-daterange'));
    this.$('input:radio[value='+this.model.get('kind')+']').trigger('click');

    return this;
  },

  onClear: function() {
    this.clearModel();
    this.clearForm();
  },

  onFromChange: function(event) {
    this.model.set('start_date', event.currentTarget.value);
    this.updateFormState();
  },

  onRequest: function() {
    this.model.save();
  },

  onToChange: function(event) {
    this.model.set('end_date', event.currentTarget.value);
    this.updateFormState();
  },

  onTypeChange: function(event) {
    this.model.set('kind', event.currentTarget.value);
    this.updateFormState();
  },

  onError: function(model, response, options) {
    var message = 'ERROR ' + response.status.toString();

    if (response.status === 422) {
      message = response.responseJSON.errors.join('\n');
    }

    alert(message);
  },

  onInvalid: function(model, response, options) {
    var message = _.values(model.validationError).join('\n');
    alert(message);
  },

  onSuccess: function(model, response, options) {
    // Trigger 'sync' on the collection to initiate it's view,
    // VacationRequestsList, about changes.
    this.vacationRequests.fetch();
    // TODO: add some tests
    // Clear model to set it as a new one,
    // and initialize it with form data.
    // Otherwise, the model is initialized with response data and a next save()
    // will emit PUT request (update) instead of POST (create)
    this.clearModel();
    this.fetchFormData();
  },

  fetchFormData: function () {
    this.model.set('kind',              this.$('input:radio[name=vacation-type]:checked').val());
    this.model.set('start_date',        this.$('input[name=from]').val());
    this.model.set('end_date',          this.$('input[name=to]').val());
  },

  clearForm: function () {
    this.$('input[name=from]').val('').trigger('change').datepicker('update');
    this.$('input[name=to]').val('').trigger('change').datepicker('update');
    this.$('input:radio[value='+this.model.get('kind')+']').trigger('click');
  },

  clearModel: function () {
    // TODO: add some feature tests
    // this.model = new App.Models.VacationRequest();
    this.model.clear();
    this.model.set(this.model.defaults);
  },

  updateAvailableDaysInBadges: function() {
    var $badge;

    this.availableVacations.each(function(model) {
      $badge = this.$('.badge.'+model.attributes.kind);
      $badge.text(this.model.calculateDuration(this.holidays)+'|'+Math.floor(model.attributes.available_days));
    }, this);
  },

  updateFormState: function() {
    this.updateAvailableDaysInBadges();
    this.updateRequestButtonState();
  },

  updateRequestButtonState: function() {
    var isWrongDuration = true,
        $button = this.$('button[name=request]');

    isWrongDuration = ((this.availableVacations.availableDaysOfType(this.model.get('kind')) - this.model.calculateDuration(this.holidays)) < 0);

    if (isWrongDuration) {
      $button.removeClass('btn-default');
      $button.addClass('btn-danger');
    } else {
      $button.removeClass('btn-danger');
      $button.addClass('btn-default');
    }
  }
});
