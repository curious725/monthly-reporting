describe('ApprovalRequest model', function() {
  beforeEach(function() {
    this.model = new App.Models.ApprovalRequest();
  });

  it('is able to create its instance', function() {
    expect(this.model).toBeDefined();
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


  describe('as a new instance', function() {
    describe('sets its attribute properly,', function() {
      it('first_name=""', function() {
        expect(this.model.get('first_name')).toEqual('');
      });
      it('last_name=""', function() {
        expect(this.model.get('last_name')).toEqual('');
      });
      it('kind="planned"', function() {
        expect(this.model.get('kind')).toEqual(App.Vacation.types.planned);
      });
      it('start_date=""', function() {
        expect(this.model.get('start_date')).toEqual('');
      });
      it('end_date=""', function() {
        expect(this.model.get('end_date')).toEqual('');
      });
    });
  });

  describe('.set', function() {
    it('does not allow to set not expected attributes', function() {
      var predefined_object = {
            'first_name':'',
            'last_name':'',
            'kind': App.Vacation.types.planned,
            'alien_attribute':'',
          },
          that = this;
      expect(function(){that.model.set(predefined_object);}).toThrow();
    });

    it('sets attributes from object', function() {
      var predefined_object = {
            'first_name':'',
            'last_name':'',
            'kind': App.Vacation.types.planned,
            'start_date':'',
            'end_date':''
          },
          that = this;
      expect(function(){that.model.set(predefined_object);}).not.toThrow();
    });
  });
});
