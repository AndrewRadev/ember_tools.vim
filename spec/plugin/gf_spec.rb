require 'spec_helper'

describe "gf mapping" do
  describe "javascript/handlebars" do
    specify "finding a route" do
      touch_file 'app/routes/foo/bar-baz.js'
      edit_file 'app/router.js', <<-EOF
        this.route('foo', function() {
          this.route('bar-baz');
        })
      EOF
      vim.search 'bar-baz'

      vim.normal 'gf'

      expect(current_file).to eq 'app/routes/foo/bar-baz.js'
    end

    specify "finding a component" do
      touch_file 'app/components/foo/bar-baz/template.hbs'
      edit_file 'app/templates/example.hbs', <<-EOF
        <p>
          {{foo/bar-baz param1=something}}
        </p>
      EOF
      vim.search 'foo/bar-baz'

      vim.normal 'gf'

      expect(current_file).to eq 'app/components/foo/bar-baz/template.hbs'
    end

    specify "finding a controller action" do
      edit_file 'app/controllers/foo.js', <<-EOF
        export default Ember.Controller.extend({
          actions: {
            exampleAction() {
              # example
            }
          }
        });
      EOF
      edit_file 'app/templates/foo.hbs', <<-EOF
        <p>
          {{foo/bar-baz param1=(action 'exampleAction')}}
        </p>
      EOF
      vim.search 'exampleAction'

      vim.normal 'gf'

      expect(current_file).to eq 'app/controllers/foo.js'
      expect(current_line.strip).to eq 'exampleAction() {'
    end

    specify "finding a component action" do
      edit_file 'app/components/foo/bar-baz/component.js', <<-EOF
        export default Ember.Component.extend({
          actions: {
            exampleAction() {
              # example
            }
          }
        });
      EOF
      edit_file 'app/components/foo/bar-baz/template.hbs', <<-EOF
        <p>
          {{foo/bar-baz param1=(action 'exampleAction')}}
        </p>
      EOF
      vim.search 'exampleAction'

      vim.normal 'gf'

      expect(current_file).to eq 'app/components/foo/bar-baz/component.js'
      expect(current_line.strip).to eq 'exampleAction() {'
    end

    describe "finding a service" do
      before :each do
        touch_file 'app/services/example-service.js'
        edit_file 'app/routes/example-route.js', <<-EOF
          export default Ember.Route.extend({
            exampleService: Ember.inject.service()
          });

          beforeModel: function() {
            this.get('exampleService.exampleProperty').doSomething();
          }
        EOF
      end

      it "finds a service from its inject() line" do
        vim.search 'exampleService: Ember.inject.service()'
        vim.normal 'gf'
        expect(current_file).to eq 'app/services/example-service.js'
      end

      it "finds a service from its inject() line" do
        vim.search 'this.get(\'\zsexampleService.'
        vim.normal 'gf'
        expect(current_file).to eq 'app/services/example-service.js'
      end
    end

    describe "finding a model" do
      before :each do
        touch_file 'app/models/example-model.js'
        touch_file 'app/models/other-model.js'
        edit_file 'app/routes/example-route.js', <<-EOF
          export default Ember.Route.extend({
            model() {
              this.store.createRecord('example-model')
              this.modelFor('example-model')
            }
          });

          export default Ember.Model.extend({
            otherModel: DS.belongsTo("otherModel", async: false)
            otherModel: DS.hasMany("otherModel", async: true)
          });
        EOF
      end

      it "finds a model from its createRecord() line" do
        vim.search 'createRecord'
        vim.normal 'gf'
        expect(current_file).to eq 'app/models/example-model.js'
      end

      it "finds a model from its modelFor() line" do
        vim.search 'modelFor'
        vim.normal 'gf'
        expect(current_file).to eq 'app/models/example-model.js'
      end

      it "finds a model from its belongsTo() line" do
        vim.search 'belongsTo'
        vim.normal 'gf'
        expect(current_file).to eq 'app/models/other-model.js'
      end

      it "finds a model from its hasMany() line" do
        vim.search 'hasMany'
        vim.normal 'gf'
        expect(current_file).to eq 'app/models/other-model.js'
      end
    end
  end

  describe "coffee/emblem" do
    specify "finding a route" do
      touch_file 'app/routes/foo/bar-baz.coffee'
      edit_file 'app/router.coffee', <<-EOF
        @route 'foo', ->
          @route 'bar-baz'
      EOF
      vim.search 'bar-baz'

      vim.normal 'gf'

      expect(current_file).to eq 'app/routes/foo/bar-baz.coffee'
    end

    specify "finding a component" do
      touch_file 'app/components/foo/bar-baz/template.emblem'
      edit_file 'app/templates/example.emblem', <<-EOF
        p
          = foo/bar-baz param1=something
      EOF
      vim.search 'foo/bar-baz'

      vim.normal 'gf'

      expect(current_file).to eq 'app/components/foo/bar-baz/template.emblem'
    end

    specify "finding a controller action" do
      edit_file 'app/controllers/foo.coffee', <<-EOF
        controller = Ember.Controller.extend
          actions:
            exampleAction: ->
              # example
      EOF
      edit_file 'app/templates/foo.emblem', <<-EOF
        p
          = foo/bar-baz param1=(action 'exampleAction')
      EOF
      vim.search 'exampleAction'

      vim.normal 'gf'

      expect(current_file).to eq 'app/controllers/foo.coffee'
      expect(current_line.strip).to eq 'exampleAction: ->'
    end

    specify "finding a component action" do
      edit_file 'app/components/foo/component.coffee', <<-EOF
        component = Ember.Component.extend
          actions:
            exampleAction: ->
              # example
      EOF
      edit_file 'app/components/foo/template.emblem', <<-EOF
        p
          = foo/bar-baz param1=(action 'exampleAction')
      EOF
      vim.search 'exampleAction'

      vim.normal 'gf'

      expect(current_file).to eq 'app/components/foo/component.coffee'
      expect(current_line.strip).to eq 'exampleAction: ->'
    end

    describe "finding a service" do
      before :each do
        touch_file 'app/services/example-service.coffee'
        edit_file 'app/routes/example-route.coffee', <<-EOF
          route = Ember.Route.extend
            exampleService: Ember.inject.service()

          beforeModel: ->
            @get('exampleService.exampleProperty').doSomething()
        EOF
      end

      it "finds a service from its inject() line" do
        vim.search 'exampleService: Ember.inject.service()'
        vim.normal 'gf'
        expect(current_file).to eq 'app/services/example-service.coffee'
      end

      it "finds a service from its inject() line" do
        vim.search '@get(\'\zsexampleService.'
        vim.normal 'gf'
        expect(current_file).to eq 'app/services/example-service.coffee'
      end
    end

    describe "finding a model" do
      before :each do
        touch_file 'app/models/example-model.coffee'
        touch_file 'app/models/other-model.coffee'
        edit_file 'app/routes/example-route.coffee', <<-EOF
          route = Ember.Route.extend
            model: ->
              @store.createRecord('example-model')
              @modelFor('example-model')

          model = Ember.Model.extend
            otherModel: DS.belongsTo("otherModel", async: false)
            otherModel: DS.hasMany("otherModel", async: true)
        EOF
      end

      it "finds a model from its createRecord() line" do
        vim.search 'createRecord'
        vim.normal 'gf'
        expect(current_file).to eq 'app/models/example-model.coffee'
      end

      it "finds a model from its modelFor() line" do
        vim.search 'modelFor'
        vim.normal 'gf'
        expect(current_file).to eq 'app/models/example-model.coffee'
      end

      it "finds a model from its belongsTo() line" do
        vim.search 'belongsTo'
        vim.normal 'gf'
        expect(current_file).to eq 'app/models/other-model.coffee'
      end

      it "finds a model from its hasMany() line" do
        vim.search 'hasMany'
        vim.normal 'gf'
        expect(current_file).to eq 'app/models/other-model.coffee'
      end
    end
  end
end
