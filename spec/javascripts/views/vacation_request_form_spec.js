describe('VacationRequestForm view', function() {
  beforeEach(function() {
    // Stub User roles
    App.currentUserRoles = new App.Collections.CurrentUserRoles([
      {'id':1, 'team_id':1, 'role':'guest'}
    ]);

    this.holidays = new App.Collections.Holidays([
      {"id":4,"description":"Independence Day","start":"2015-08-24","duration":2},
      {"id":7,"description":"Constitution Day","start":"2015-06-28","duration":2},
      {"id":10,"description":"New Year's Day","start":"2015-01-01","duration":2}
    ]);
    this.availableVacations = new App.Collections.AvailableVacations([
      {'id':1,'kind':'planned','available_days':35.0,'user_id':1},
      {'id':2,'kind':'sickness','available_days':14.0,'user_id':1},
      {'id':3,'kind':'unpaid','available_days':5.0,'user_id':1}
    ]);

    setFixtures('<div class="new-vacation-request-form"></div>');
    this.container = $('.new-vacation-request-form');

    this.view = new App.Views.VacationRequestForm({
      'holidays': this.holidays,
      'availableVacations': this.availableVacations
    });
    this.container.append(this.view.render().el);
  });

  afterEach(function() {
    this.view.remove();
  });

  it('has its .model attribute defined', function() {
    expect(this.view.model).toBeDefined();
  });

  it('has its .model of type App.Models.VacationRequest', function() {
    expect(this.view.model).toEqual(jasmine.any(App.Models.VacationRequest));
  });

  it('returns the view object with its .render() method', function() {
    expect(this.view.render()).toEqual(this.view);
  });

  describe('.updateAvailableDaysInBadges()', function() {
    beforeEach(function() {
      this.badgePlanned   = this.view.$('.badge.planned');
      this.badgeSickness  = this.view.$('.badge.sickness');
      this.badgeUnpaid    = this.view.$('.badge.unpaid');

      this.badgePlanned.text('');
      this.badgeSickness.text('');
      this.badgeUnpaid.text('');
    });

    it('sets all the radio button group badges with up-to-date information', function() {
      var newText = '';
      expect(this.view.$('.badge').length).toEqual(3);

      expect(this.badgePlanned).toHaveText('');
      expect(this.badgeSickness).toHaveText('');
      expect(this.badgeUnpaid).toHaveText('');

      this.view.updateAvailableDaysInBadges();

      newText = this.view.model.calculateDuration(this.holidays)+'|'+this.view.availableVacations.availableDaysOfType('planned');
      expect(this.badgePlanned).toHaveText(newText);
      newText = this.view.model.calculateDuration(this.holidays)+'|'+this.view.availableVacations.availableDaysOfType('sickness');
      expect(this.badgeSickness).toHaveText(newText);
      newText = this.view.model.calculateDuration(this.holidays)+'|'+this.view.availableVacations.availableDaysOfType('unpaid');
      expect(this.badgeUnpaid).toHaveText(newText);
    });
  });

  describe('.updateRequestButtonState()', function() {
    beforeEach(function() {
      this.button = this.view.$('button[name=request]');
    });

    describe('with vacation duration greater than available days in selected vacation type', function() {
      beforeEach(function() {
        this.view.model.set('kind','unpaid');
        this.view.model.set('start_date','2015-01-01');
        this.view.model.set('end_date','2015-01-25');
      });

      it('changes button[name=request] color to red', function() {
        var duration = this.view.model.calculateDuration(this.holidays),
            availableDays = this.view.availableVacations.availableDaysOfType(this.view.model.get('kind'));

        expect(duration > availableDays).toBeTruthy();
        expect(this.button).toHaveClass('btn-default');

        this.view.updateRequestButtonState();
        expect(this.button).toHaveClass('btn-danger');
      });
    });

    describe('with vacation duration less than or equal to available days in selected vacation type', function() {
      beforeEach(function() {
        this.view.model.set('kind','unpaid');
        this.view.model.set('start_date','2015-01-01');
        this.view.model.set('end_date','2015-01-10');

        this.button.removeClass('btn-default');
        this.button.addClass('btn-danger');
      });

      it('changes button[name=request] color to default one', function() {
        var duration = this.view.model.calculateDuration(this.holidays),
            availableDays = this.view.availableVacations.availableDaysOfType(this.view.model.get('kind'));

        expect(duration <= availableDays).toBeTruthy();
        expect(this.button).toHaveClass('btn-danger');

        this.view.updateRequestButtonState();
        expect(this.button).not.toHaveClass('btn-danger');
        expect(this.button).toHaveClass('btn-default');
      });
    });
  });

  describe('responds to jQuery event', function() {
    it('click button[name=clear]', function() {
      var htmlElement = this.view.$('button[name=clear]'),
          inputFrom = this.view.$('input[name=from]'),
          inputTo = this.view.$('input[name=to]');

      inputFrom.val('2015-01-01');
      inputTo.val('2015-01-05');
      expect(inputFrom).toHaveValue('2015-01-01');
      expect(inputTo).toHaveValue('2015-01-05');

      spyOn(this.view, 'onClear').and.callThrough();
      this.view.delegateEvents();

      htmlElement.trigger('click');
      expect(this.view.onClear).toHaveBeenCalled();
      expect(inputFrom).toHaveValue('');
      expect(inputTo).toHaveValue('');
    });

    it('change input[name=from]', function() {
      var htmlElement = this.view.$('input[name=from]'),
          oldValue = this.view.model.get('start_date'),
          newValue = '2015-01-01';

      spyOn(this.view, 'onFromChange').and.callThrough();
      this.view.delegateEvents();

      expect(htmlElement.val()).toEqual(oldValue);

      htmlElement.val(newValue);
      htmlElement.trigger('change');
      expect(this.view.onFromChange).toHaveBeenCalled();
      expect(this.view.model.get('start_date')).toEqual(newValue);
    });

    it('click button[name=request]', function() {
      var htmlElement = this.view.$('button[name=request]');
      spyOn(this.view, 'onRequest');
      this.view.delegateEvents();

      htmlElement.trigger('click');
      expect(this.view.onRequest).toHaveBeenCalled();
    });

    it('change input[name=to]', function() {
      var htmlElement = this.view.$('input[name=to]'),
          oldValue = this.view.model.get('end_date'),
          newValue = '2015-01-01';

      spyOn(this.view, 'onToChange').and.callThrough();
      this.view.delegateEvents();

      htmlElement.val(newValue);
      htmlElement.trigger('change');
      expect(this.view.onToChange).toHaveBeenCalled();
      expect(this.view.model.get('end_date')).toEqual(newValue);
    });

    it('change input:radio[name=vacation-type]', function() {
      var htmlElement = this.view.$('input:radio[name=vacation-type]'),
          oldValue = this.view.model.get('kind'),
          newValue = 'unpaid';

      expect(htmlElement.val()).toEqual(oldValue);
      expect($(htmlElement.selector+'[value=planned]')[0].parentElement).toHaveClass('active');

      spyOn(this.view, 'onTypeChange').and.callThrough();
      this.view.delegateEvents();

      htmlElement.val(newValue);
      htmlElement.trigger('change');
      expect(this.view.onTypeChange).toHaveBeenCalled();
      expect(this.view.model.get('kind')).toEqual(newValue);
    });
  });

  describe('produces correct HTML', function() {
    beforeEach(function() {
      this.datePickerContainer = this.view.$('.input-daterange');
      this.toggleButtonWrapper = this.view.$('.btn.btn-default');
      this.toggleButtonPlanned = this.toggleButtonWrapper.find('input:radio[name=vacation-type][value="planned"]');
    });

    it('.btn.btn-default', function() {
      expect(this.view.el).toContainElement(this.toggleButtonWrapper);
      expect('.btn.btn-default > input').toHaveLength(3);
      expect('.btn.btn-default > .badge').toHaveLength(3);
    });

    it('input:radio[name=vacation-type][value="planned"]', function() {
      expect(this.toggleButtonWrapper[0]).toContainElement('input:radio[name=vacation-type][value="planned"]');
      expect(this.toggleButtonWrapper[0]).toContainElement('.badge.planned');
      var days = this.availableVacations.models[0].attributes.available_days;
      expect(this.toggleButtonWrapper.selector+' .badge.planned').toHaveText('1|'+days.toString());
      expect(this.toggleButtonWrapper[0]).toContainText('planned');
    });

    it('input:radio[name=vacation-type][value="sickness"]', function() {
      expect(this.toggleButtonWrapper[1]).toContainElement('input:radio[name=vacation-type][value="sickness"]');
      expect(this.toggleButtonWrapper[1]).toContainElement('.badge.sickness');
      var days = this.availableVacations.models[1].attributes.available_days;
      expect(this.toggleButtonWrapper.selector+' .badge.sickness').toHaveText('1|'+days.toString());
      expect(this.toggleButtonWrapper[1]).toContainText('sickness');
    });

    it('input:radio[name=vacation-type][value="unpaid"]', function() {
      expect(this.toggleButtonWrapper[2]).toContainElement('input:radio[name=vacation-type][value="unpaid"]');
      expect(this.toggleButtonWrapper[2]).toContainElement('.badge.unpaid');
      var days = this.availableVacations.models[2].attributes.available_days;
      expect(this.toggleButtonWrapper.selector+' .badge.unpaid').toHaveText('1|'+days.toString());
      expect(this.toggleButtonWrapper[2]).toContainText('unpaid');
    });

    it('input:text[name=from]', function() {
      expect(this.datePickerContainer).toContainElement('input:text[name=from]');
    });
    it('input:text[name=to]', function() {
      expect(this.datePickerContainer).toContainElement('input:text[name=to]');
    });

    it('button[name=clear]', function() {
      expect(this.view.el).toContainElement('button[name=clear]');
    });
    it('button[name=request]', function() {
      expect(this.view.el).toContainElement('button[name=request]');
    });
  });
});
