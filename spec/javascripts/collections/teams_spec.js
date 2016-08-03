describe('Teams collection', function() {
  beforeEach(function() {
    this.collection = new App.Collections.Teams();
  });

  it('should be able to create its instance object', function() {
    expect(this.collection).toBeDefined();
  });

  it('should be able to add model instances as objects', function() {
    expect(this.collection.length).toBe(0);

    this.collection.add({'name':'SuperAnts'});
    expect(this.collection.length).toBe(1);

    var team = new App.Models.Team();
    this.collection.add(team);
    expect(this.collection.length).toBe(2);
  });

  it('should be able to add model instances as arrays', function() {
    expect(this.collection.length).toBe(0);

    this.collection.add([
      {'name':'SuperAnts'},
      {'name':'Valiants'}
    ]);
    expect(this.collection.length).toBe(2);

    this.collection.add([
      new App.Models.Team({'name':'SuperAnts'}),
      new App.Models.Team({'name':'Valiants'}),
    ]);
    expect(this.collection.length).toBe(4);
  });

  describe('as a brand new object', function() {
    it('should have its .length attribute to be zero', function() {
      expect(this.collection.length).toBe(0);
    });

    it('should have its .url attribute set to "/teams"', function() {
      expect(this.collection.url).toEqual('/teams');
    });

    it('should have its .model attribute defined', function() {
      expect(this.collection.model).toBeDefined();
    });
  });
});
