describe('App.Helpers.arrayOfWeekends', function() {
  beforeEach(function() {
    this.subject = App.Helpers.arrayOfWeekends;
  });

  it('exists', function() {
    expect(this.subject).toBeDefined();
  });
  it('is a method', function() {
    expect(typeof this.subject).toEqual('function');
  });
  it('expects two parameters', function() {
    expect(this.subject.length).toEqual(2);
  });

  describe('with valid parameters which set date range', function() {
    describe('without weekends', function() {
      beforeEach(function() {
        this.parameters = ['2015-01-05',5];
        this.result = [];
      });
      it('returns empty array', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });

    describe('with one weekend', function() {
      beforeEach(function() {
        this.parameters = ['2015-01-01',3];
        this.result = ['2015-01-03'];
      });
      it('returns array of one date', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });

    describe('with five weekends', function() {
      beforeEach(function() {
        this.parameters = ['2015-01-01',17];
        this.result = ['2015-01-03','2015-01-04','2015-01-10','2015-01-11','2015-01-17'];
      });
      it('returns array of five dates', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });
  });

  describe('with valid "start" parameter that represents 2015-01-03 in different allowed formats, and duration=1', function() {
    describe('"YYYY-MM-DD"', function() {
      beforeEach(function() {
        this.parameters = ['2015-01-03',1];
        this.result = ['2015-01-03'];
      });
      it('returns array of one date', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });
    describe('"YYYY/MM/DD"', function() {
      beforeEach(function() {
        this.parameters = ['2015/01/03',1];
        this.result = ['2015-01-03'];
      });
      it('returns array of one date', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });
    describe('"YYYY MM DD"', function() {
      beforeEach(function() {
        this.parameters = ['2015 01 03',1];
        this.result = ['2015-01-03'];
      });
      it('returns array of one date', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });
  });

  describe('with not valid "duration" parameter', function() {
    describe('duration=0', function() {
      beforeEach(function() {
        this.parameters = ['2015-01-05',0];
        this.result = [];
      });
      it('returns empty array', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });

    describe('duration=-1', function() {
      beforeEach(function() {
        this.parameters = ['2015-01-05',-1];
        this.result = [];
      });
      it('returns empty array', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });

    describe('duration="text"', function() {
      beforeEach(function() {
        this.parameters = ['2015-01-05','text'];
        this.result = [];
      });
      it('returns empty array', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });

    describe('duration=null', function() {
      beforeEach(function() {
        this.parameters = ['2015-01-05',null];
        this.result = [];
      });
      it('returns empty array', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });
  });

  describe('with not valid "start" parameter', function() {
    describe('start="2015"', function() {
      beforeEach(function() {
        this.parameters = ['2015',1];
        this.result = [];
      });
      it('returns empty array', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });

    describe('start="2015-01"', function() {
      beforeEach(function() {
        this.parameters = ['2015-01',1];
        this.result = [];
      });
      it('returns empty array', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });

    describe('start="2015-01-01-01"', function() {
      beforeEach(function() {
        this.parameters = ['2015-01-01-01',1];
        this.result = [];
      });
      it('returns empty array', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });

    describe('start="20150103"', function() {
      beforeEach(function() {
        this.parameters = ['20150103',1];
        this.result = [];
      });
      it('returns empty array', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });

    describe('start="2015*01*03"', function() {
      beforeEach(function() {
        this.parameters = ['2015*01*03',1];
        this.result = [];
      });
      it('returns empty array', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });

    describe('start=0', function() {
      beforeEach(function() {
        this.parameters = [0,1];
        this.result = [];
      });
      it('returns empty array', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });

    describe('start=-1', function() {
      beforeEach(function() {
        this.parameters = [-1,1];
        this.result = [];
      });
      it('returns empty array', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });

    describe('start="0000000000"', function() {
      beforeEach(function() {
        this.parameters = ['0000000000',1];
        this.result = [];
      });
      it('returns empty array', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });

    describe('start=null', function() {
      beforeEach(function() {
        this.parameters = [null,1];
        this.result = [];
      });
      it('returns empty array', function() {
        expect(this.subject.apply(this, this.parameters)).toEqual(this.result);
      });
    });
  });
});
