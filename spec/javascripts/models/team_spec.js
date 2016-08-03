describe('Team model', function() {
  beforeEach(function() {
    this.model = new App.Models.Team();
  });

  it('should be able to create its instance object', function() {
    expect(this.model).toBeDefined();
  });

  describe('with Backbone.Validation mixin', function() {
    it('should have .validate() method', function() {
      expect(this.model.isValid).toBeDefined();
    });

    it('should have .isValid() method', function() {
      expect(this.model.isValid).toBeDefined();
    });

    it('should have .preValidate() method', function() {
      expect(this.model.preValidate).toBeDefined();
    });
  });

  describe('as a brand new object', function() {
    it('should have its .name attribute to be empty string', function() {
      expect(this.model.get('name')).toEqual('');
    });

    it('should validate .name attribute with proper error message', function() {
      var errors  = this.model.validate();

      expect(errors.name).toEqual('Name is required');
    });

    it('should be invalid', function() {
      var isValid = this.model.isValid(true);
      expect(isValid).toBeFalsy();
    });
  });

  describe('with invalid attributes,', function() {
    describe('name="Ants"', function() {
      beforeEach(function() {
        this.value = 'Ants';
        this.model.set('name', this.value);
      });

      it('should have properly set attribute', function() {
        expect(this.model.get('name')).toEqual(this.value);
      });

      it('should validate attribute with proper error message', function() {
        var errors  = this.model.validate();

        expect(errors.name).toEqual('Name must be between 5 and 35 characters');
      });

      it('should be invalid', function() {
        var isValid = this.model.isValid(true);
        expect(isValid).toBeFalsy();
      });
    });

    describe('name="SuperMegaIncrediblyTurboQuickAnts!!!"', function() {
      beforeEach(function() {
        this.value = 'SuperMegaIncrediblyTurboQuickAnts!!!';
        this.model.set('name', this.value);
      });

      it('should have properly set attribute', function() {
        expect(this.model.get('name')).toEqual(this.value);
      });

      it('should validate attribute with proper error message', function() {
        var errors  = this.model.validate();

        expect(errors.name).toEqual('Name must be between 5 and 35 characters');
      });

      it('should be invalid', function() {
        var isValid = this.model.isValid(true);
        expect(isValid).toBeFalsy();
      });
    });
  });

  describe('with valid attributes,', function() {
    describe('name="SuperAnts"', function() {
      beforeEach(function() {
        this.value = 'SuperAnts';
        this.model.set('name',this.value);
      });

      it('should have properly set attribute', function() {
        expect(this.model.get('name')).toEqual(this.value);
      });

      it('should validate attribute without any error messages', function() {
        var errors  = this.model.validate();

        expect(errors).toBeUndefined();
      });

      it('should be valid', function() {
        var isValid = this.model.isValid(true);
        expect(isValid).toBeTruthy();
      });
    });
  });
});
