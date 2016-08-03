describe('Teams view', function() {
  beforeEach(function() {
    setFixtures('<section></section>');
    var collection = new App.Collections.Teams([
      {'name':'Valiants'},
      {'name':'SuperAnts'},
      {'name':'Angrybirds'}
    ]);

    // Stub User roles
    App.currentUserRoles = new App.Collections.CurrentUserRoles([
      {'id':1, 'role':'admin'}
    ]);

    this.view = new App.Views.Teams({'collection':collection});
    this.view.render();
    this.container = $('#teams');
  });

  afterEach(function() {
    this.view.remove();
  });


  it('has its attributes properly set', function() {
    expect(this.view.$el).toBeDefined();
    expect(this.view.$el.selector).toBe('section');
    expect(this.view.collection).toBeDefined();
    expect(this.view.collection.length).toBe(3);
  });

  it('has its .render() method returning the view object', function() {
    expect(this.view.render()).toEqual(this.view);
  });

  it('produces correct HTML', function() {
    expect(this.container).toContainElement('form.team-create');
    expect(this.container).toContainElement('input[name=team-name]');
    expect(this.container).toContainElement('button[name=add]');
    expect(this.container).toContainElement('ul.teams-list');
    expect(this.container.find('li:first-child .view')).toHaveText('Valiants');
    expect(this.container.find('li:last-child .view')).toHaveText('Angrybirds');
  });

  describe('responds to jQuery event', function() {
    it('click button[name=add]', function() {
      var addButton = this.container.find('button[name=add]');
      spyOn(this.view, 'onAddTeam').and.callThrough();
      this.view.delegateEvents();

      addButton.trigger('click');
      expect(this.view.onAddTeam).toHaveBeenCalled();
    });
  });

  describe('responds to user input confirmation, and', function() {
    beforeEach(function() {
      this.inputField = this.container.find('input[name=team-name]');
      this.addButton  = this.container.find('button[name=add]');
    });
    describe('if the value of the edit form is not valid,', function() {
      describe('name="Ants"', function() {
        it('nothing is added to the list', function() {
          expect(this.view.collection.length).toBe(3);

          this.inputField.val('Ants');
          this.addButton.trigger('click');
          expect(this.view.collection.length).toBe(3);
        });
      });

      describe('name=""', function() {
        it('nothing is added to the list', function() {
          expect(this.view.collection.length).toBe(3);

          this.inputField.val('');
          this.addButton.trigger('click');
          expect(this.view.collection.length).toBe(3);
        });
      });
    });

    describe('if the value of the edit form is valid,', function() {
      describe('name="Warlords"', function() {
        it('a new team is added to the list', function() {
          expect(this.view.collection.length).toBe(3);

          this.inputField.val('Warlords');
          this.addButton.trigger('click');
          expect(this.view.collection.length).toBe(4);
        });
      });
    });
  });
});
