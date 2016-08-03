describe('VacationRequest view', function() {
  beforeEach(function() {
    // Stub User roles
    App.currentUserRoles = new App.Collections.CurrentUserRoles([
      {'id':1, 'team_id':1, 'role':'guest'}
    ]);

    this.model = new App.Models.VacationRequest({
      'id': 1,
      'kind':'planned',
      'status':'requested',
      'start_date':'2015-08-01',
      'end_date':'2015-08-11',
    });

    this.view = new App.Views.VacationRequest({'model': this.model});
  });

  afterEach(function() {
    this.view.remove();
  });

  describe('as a real object', function() {
    it('has its .model attribute defined', function() {
      expect(this.view.model).toBeDefined();
    });

    it('has its .model of type App.Models.VacationRequest', function() {
      expect(this.view.model).toEqual(jasmine.any(App.Models.VacationRequest));
    });

    it('has its .tagName properly set', function() {
      expect(this.view.el.tagName.toLowerCase()).toBe('tr');
    });

    it('returns the view object with its .render() method', function() {
      expect(this.view.render()).toEqual(this.view);
    });

    it('produces the correct HTML', function() {
      setFixtures('<table><tbody></tbody></table>');
      this.container = $('tbody');
      this.container.append(this.view.render().el);

      expect($('td')[0].innerHTML).toContain(this.view.attributes.start);
      expect($('td')[0].innerHTML).toContain(this.view.attributes.finish);
      expect($('td')[1].innerHTML).toContain(this.view.attributes.status);
      expect($('td')[2].innerHTML).toContain(this.view.attributes.ref);
    });
  });

  it('does not respond to jQuery events', function() {
    expect(this.view.events).toBeUndefined();
  });
});
