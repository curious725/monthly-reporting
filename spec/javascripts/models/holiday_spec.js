describe('Holiday model', function() {
  beforeEach(function() {
    this.model = new App.Models.Holiday();
  });

  it('is able to create its instance', function() {
    expect(this.model).toBeDefined();
  });

  it('has .validateNewValues() method', function() {
    expect(this.model.validateNewValues).toBeDefined();
    expect(this.model.validateNewValues).toEqual(jasmine.any(Function));
  });

  describe('.validateNewValues()', function() {
    pending();
  });

  describe('with Backbone.Validation mixin', function() {
    it('has .validate() method', function() {
      expect(this.model.validate).toBeDefined();
    });

    it('has .isValid() method', function() {
      expect(this.model.isValid).toBeDefined();
    });

    it('has .preValidate() method', function() {
      expect(this.model.preValidate).toBeDefined();
    });
  });

  describe('as a brand new object', function() {
    it('has its .description=""', function() {
      expect(this.model.get('description')).toEqual('');
    });

    it('has its .duration=1', function() {
      expect(this.model.get('duration')).toEqual(1);
    });

    it('has its .start=""', function() {
      expect(this.model.get('start')).toEqual('');
    });

    it('has proper error messages after validation', function() {
      var errors  = this.model.validate();
      expect(_.keys(errors).length).toEqual(2);
      expect(_.keys(errors)).toEqual(['description', 'start']);
      expect(errors.description).toEqual('Description is required');
      expect(errors.start).toEqual('Start is required');
    });

    it('is invalid', function() {
      var isValid = this.model.isValid(true);
      expect(isValid).toBeFalsy();
    });
  });

  describe('with invalid attributes,', function() {
    beforeEach(function() {
      this.model = new App.Models.Holiday({
        'description':  'Ruby Day',
        'duration':     1,
        'start':        '2015-08-29'
      });
    });

    describe('description="Day"', function() {
      beforeEach(function() {
        this.value = 'Day';
        this.attribute = 'description';
        this.model.set(this.attribute, this.value);
      });

      it('sets attribute properly', function() {
        expect(this.model.get(this.attribute)).toEqual(this.value);
      });

      it('validates with proper error message', function() {
        var errors  = this.model.validate();

        expect(errors[this.attribute]).toEqual('Description must be between 5 and 25 characters');
      });

      it('is invalid', function() {
        var isValid = this.model.isValid(true);
        expect(isValid).toBeFalsy();
      });
    });

    describe('duration=0', function() {
      beforeEach(function() {
        this.value = 0;
        this.attribute = 'duration';
        this.model.set(this.attribute, this.value);
      });

      it('sets attribute properly', function() {
        expect(this.model.get(this.attribute)).toEqual(this.value);
      });

      it('validates with proper error message', function() {
        var errors  = this.model.validate();

        expect(errors[this.attribute]).toEqual('Duration must be between 1 and 5');
      });

      it('is invalid', function() {
        var isValid = this.model.isValid(true);
        expect(isValid).toBeFalsy();
      });
    });

    describe('start="2015-8-25"', function() {
      beforeEach(function() {
        this.value = '2015-8-25';
        this.attribute = 'start';
        this.model.set(this.attribute, this.value);
      });

      it('sets attribute properly', function() {
        expect(this.model.get(this.attribute)).toEqual(this.value);
      });

      it('validates with proper error message', function() {
        var errors  = this.model.validate();

        expect(errors[this.attribute]).toEqual('Start must be 10 characters');
      });

      it('is invalid', function() {
        var isValid = this.model.isValid(true);
        expect(isValid).toBeFalsy();
      });
    });
  });

  describe('with valid attributes,', function() {
    beforeEach(function() {
      this.model = new App.Models.Holiday({
        'description':  'Ruby Day',
        'duration':     1,
        'start':        '2015-08-29'
      });
    });

    it('validates without any error messages', function() {
      var errors  = this.model.validate();

      expect(errors).toBeUndefined();
    });

    it('is valid', function() {
      var isValid = this.model.isValid(true);
      expect(isValid).toBeTruthy();
    });
  });
});
