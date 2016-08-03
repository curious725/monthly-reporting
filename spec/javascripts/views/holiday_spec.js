describe('Holiday view', function() {
  beforeEach(function() {
    // Stub User roles
    App.currentUserRoles = new App.Collections.CurrentUserRoles([
      {'id':1, 'team_id':1, 'role':'guest'}
    ]);

    this.model = new App.Models.Holiday({
      'description': 'Ruby Day',
      'duration': 1,
      'start': '2015-08-29'
    });

    this.view = new App.Views.Holiday({'model': this.model});
  });

  afterEach(function() {
    this.view.remove();
  });

  describe('as a real object', function() {
    beforeEach(function() {
      setFixtures('<ul class="list-group"></ul>');
      this.container = $('.list-group');
      this.container.append(this.view.render().el);
    });

    afterEach(function() {
      this.view.remove();
    });

    it('has its .model attribute defined', function() {
      expect(this.view.model).toBeDefined();
    });

    it('has its .model of type App.Models.Holiday', function() {
      expect(this.view.model).toEqual(jasmine.any(App.Models.Holiday));
    });

    it('has its .className properly set', function() {
      expect(this.view.el.className).toBe('list-group-item');
    });

    it('has its .tagName properly set', function() {
      expect(this.view.el.tagName.toLowerCase()).toBe('li');
    });

    it('returns the view object with its .render() method', function() {
      expect(this.view.render()).toEqual(this.view);
    });
  });

  describe('for user with manager role', function() {
    beforeEach(function() {
      // Stub User roles
      App.currentUserRoles = new App.Collections.CurrentUserRoles([
        {'id':1, 'team_id':1, 'role':'manager'}
      ]);

      this.view = new App.Views.Holiday({'model': this.model});
      setFixtures('<ul class="list-group"></ul>');
      this.container = $('.list-group');
      this.container.append(this.view.render().el);

      // Inline form input controls
      this.descriptionField = this.container.find('input[name=description]');
      this.fromField  = this.container.find('input[name=from]');
      this.toField    = this.container.find('input[name=to]');

      // Inline form buttons
      this.updateButton = this.container.find('button[name=update]');
      this.cancelButton = this.container.find('button[name=cancel]');
    });

    describe('responds to jQuery event', function() {
      it('click button[name=delete]', function() {
        this.deleteButton = this.container.find('button[name=delete]');
        spyOn(this.view, 'onDelete');
        this.view.delegateEvents();

        this.deleteButton.trigger('click');
        expect(this.view.onDelete).toHaveBeenCalled();
      });

      it('dblclick .view', function() {
        this.editArea = this.container.find('li .edit');
        this.viewArea = this.container.find('li .view');
        spyOn(this.view, 'enterEditMode').and.callThrough();
        this.view.delegateEvents();

        expect(this.editArea).toHaveCss({'display':'none'});

        this.viewArea.trigger('dblclick');
        expect(this.view.enterEditMode).toHaveBeenCalled();
        expect(this.editArea).toHaveCss({'display':'block'});
      });

      it('click button[name=update]', function() {
        this.updateButton = this.container.find('li button[name=update]');
        spyOn(this.view, 'onUpdate');
        this.view.delegateEvents();

        this.updateButton.trigger('click');
        expect(this.view.onUpdate).toHaveBeenCalled();
      });

      it('click button[name=cancel]', function() {
        this.updateButton = this.container.find('li button[name=cancel]');
        spyOn(this.view, 'onCancel');
        this.view.delegateEvents();

        this.updateButton.trigger('click');
        expect(this.view.onCancel).toHaveBeenCalled();
      });
    });

    describe('exposes HTML control', function() {
      it('button[name=delete]', function() {
        expect(this.container).toContainElement('button[name=delete]');
      });
      it('button[name=update]', function() {
        expect(this.container).toContainElement('button[name=update]');
      });
      it('button[name=cancel]', function() {
        expect(this.container).toContainElement('button[name=cancel]');
      });

      it('input[name=description]', function() {
        expect(this.container).toContainElement('input[name=description]');
      });
      it('input[name=from]', function() {
        expect(this.container).toContainElement('input[name=from]');
      });
      it('input[name=to]', function() {
        expect(this.container).toContainElement('input[name=to]');
      });
    });

    describe('with valid form values', function() {
      beforeEach(function() {
        // Encapsulate model inside of collection to set up url property,
        // as it is in real life
        var collection = new App.Collections.Holidays(this.view.model);

        // Fill in inline form
        this.descriptionField.val('Zero Day');
        this.fromField.val(this.view.attributes.from);
        this.toField.val(this.view.attributes.to);

        this.editArea = this.container.find('.edit');
        this.viewArea = this.container.find('.view');
        this.viewArea.trigger('dblclick');
      });

      it('allows to update record and exits edit mode', function() {
        expect(this.editArea).toHaveCss({'display':'block'});
        expect(this.descriptionField.val()).not.toEqual(this.view.model.get('description'));

        this.updateButton.trigger('click');

        expect(this.descriptionField.val()).toEqual(this.view.model.get('description'));
        expect(this.editArea).toHaveCss({'display':'none'});
      });

      it('allows to exit edit mode without updating record', function() {
        expect(this.editArea).toHaveCss({'display':'block'});
        expect(this.descriptionField.val()).not.toEqual(this.view.model.get('description'));

        this.cancelButton.trigger('click');

        expect(this.descriptionField.val()).not.toEqual(this.view.model.get('description'));
        expect(this.editArea).toHaveCss({'display':'none'});
      });
    });

    describe('with not valid form values', function() {
      beforeEach(function() {
        // Encapsulate model inside of collection to set up url property,
        // as it is in real life
        var collection = new App.Collections.Holidays(this.view.model);

        // Fill in inline form
        this.descriptionField.val('Zero');
        this.fromField.val(this.view.attributes.from);
        this.toField.val(this.view.attributes.to);

        this.editArea = this.container.find('.edit');
        this.viewArea = this.container.find('.view');
        this.viewArea.trigger('dblclick');
      });

      it('does not allow to update record and does not exit edit mode', function() {
        expect(this.editArea).toHaveCss({'display':'block'});
        expect(this.descriptionField.val()).not.toEqual(this.view.model.get('description'));

        this.updateButton.trigger('click');

        expect(this.descriptionField.val()).not.toEqual(this.view.model.get('description'));
        expect(this.editArea).toHaveCss({'display':'block'});
      });

      it('allows to exit edit mode without updating record', function() {
        expect(this.editArea).toHaveCss({'display':'block'});
        expect(this.descriptionField.val()).not.toEqual(this.view.model.get('description'));

        this.cancelButton.trigger('click');

        expect(this.descriptionField.val()).not.toEqual(this.view.model.get('description'));
        expect(this.editArea).toHaveCss({'display':'none'});
      });
    });
  });

  describe('for user without manager role', function() {
    beforeEach(function() {
      setFixtures('<ul class="list-group"></ul>');
      this.container = $('.list-group');
      this.container.append(this.view.render().el);
    });

    it('does not respond to jQuery events', function() {
      expect(this.view.events()).toEqual({});
    });

    describe('does not expose HTML control,', function() {
      it('button[name=delete]', function() {
        expect(this.container).not.toContainElement('button[name=delete]');
      });
      it('button[name=update]', function() {
        expect(this.container).not.toContainElement('button[name=update]');
      });
      it('button[name=cancel]', function() {
        expect(this.container).not.toContainElement('button[name=cancel]');
      });

      it('input[name=description]', function() {
        expect(this.container).not.toContainElement('input[name=description]');
      });
      it('input[name=from]', function() {
        expect(this.container).not.toContainElement('input[name=from]');
      });
      it('input[name=to]', function() {
        expect(this.container).not.toContainElement('input[name=to]');
      });
    });
  });
});
