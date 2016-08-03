describe('Holidays collection', function() {
  beforeEach(function() {
    this.collection = new App.Collections.Holidays();
  });

  it('is able to create its instance object', function() {
    expect(this.collection).toBeDefined();
  });

  it('is able to add model instances as objects', function() {
    expect(this.collection.length).toBe(0);

    this.collection.add({'name':'SuperAnts'});
    expect(this.collection.length).toBe(1);

    var team = new App.Models.Holiday();
    this.collection.add(team);
    expect(this.collection.length).toBe(2);
  });

  it('is able to add model instances as arrays', function() {
    expect(this.collection.length).toBe(0);

    this.collection.add([
      {'description':'Women Day'},
      {'description':'Ruby Day'}
    ]);
    expect(this.collection.length).toBe(2);

    this.collection.add([
      new App.Models.Holiday(),
      new App.Models.Holiday(),
    ]);
    expect(this.collection.length).toBe(4);
  });

  it('has .arrayOfDates() method', function() {
    expect(this.collection.arrayOfDates).toBeDefined();
    expect(this.collection.arrayOfDates).toEqual(jasmine.any(Function));
  });

  describe('with .arrayOfDates()', function() {
    beforeEach(function() {
      this.collection = new App.Collections.Holidays([
        {'start':'2015-09-01', 'duration':1},
        {'start':'2015-05-01', 'duration':2},
        {'start':'2015-04-01', 'duration':3},
        {'start':'2015-01-01', 'duration':2}
      ]);

      this.result = ['2015-09-01','2015-05-01','2015-05-02','2015-04-01','2015-04-02','2015-04-03','2015-01-01','2015-01-02'];
    });

    it('provides array of dates', function() {
      expect(this.collection.arrayOfDates()).toEqual(this.result.sort());
    });
  });

  describe('as a brand new object', function() {
    it('has its .comparator="start"', function() {
      expect(this.collection.comparator).toEqual('start');
    });

    it('has its .model=App.Models.Holiday', function() {
      expect(this.collection.model).toBe(App.Models.Holiday);
    });

    it('has its .url="/holidays"', function() {
      expect(this.collection.url).toEqual('/holidays');
    });

    it('has its .length=0', function() {
      expect(this.collection.length).toBe(0);
    });
  });
});
