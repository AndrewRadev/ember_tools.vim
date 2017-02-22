require 'spec_helper'
require 'json'

describe "gf mapping" do
  describe "javascript/handlebars" do
    specify "finding a relative import" do
      touch_file 'app/stuff.js'
      edit_file 'app/foo/bar/baz.js', <<-EOF
        import stuff from '../../stuff';
      EOF
      vim.search 'stuff\''

      vim.normal 'gf'

      expect(current_file).to eq 'app/stuff.js'
    end

    specify "finding an app-relative import" do
      write_file 'package.json', JSON.dump({'name' => 'appname'})
      touch_file 'app/stuff.js'
      edit_file 'app/foo/bar/baz.js', <<-EOF
        import stuff from 'appname/stuff';
      EOF
      vim.search 'stuff\''

      vim.normal 'gf'

      expect(current_file).to eq 'app/stuff.js'
    end

    specify "finding a route from the router" do
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

    specify "finding a route from a transitionTo" do
      touch_file 'app/routes/foo/bar-baz.js'
      edit_file 'app/controllers/foo.js', <<-EOF
        beforeModel() {
          this.transitionTo('foo.bar-baz');
        }
      EOF
      vim.search 'foo.bar-baz'

      vim.normal 'gf'

      expect(current_file).to eq 'app/routes/foo/bar-baz.js'
    end

    specify "finding a route in a pod structure" do
      touch_file 'app/pods/foo/bar-baz/route.js'
      edit_file 'app/router.js', <<-EOF
        this.route('foo', function() {
          this.route('bar-baz');
        })
      EOF
      vim.search 'bar-baz'

      vim.normal 'gf'

      expect(current_file).to eq 'app/pods/foo/bar-baz/route.js'
    end

    specify "finding a route with an index.js file" do
      touch_file 'app/routes/foo/bar-baz/index.js'
      edit_file 'app/router.js', <<-EOF
        this.route('foo', function() {
          this.route('bar-baz');
        })
      EOF
      vim.search 'bar-baz'

      vim.normal 'gf'

      expect(current_file).to eq 'app/routes/foo/bar-baz/index.js'
    end

    specify "finding a controller" do
      touch_file 'app/controllers/foo/bar.js'
      edit_file 'app/routes/baz.js', <<-EOF
        export default Ember.Controller.extend({
          exampleAction() {
            let controller = this.controllerFor('foo.bar')
          }
        });
      EOF
      vim.search 'controllerFor'

      vim.normal 'gf'

      expect(current_file).to eq 'app/controllers/foo/bar.js'
    end

    specify "finding a controller within a pod structure" do
      touch_file 'app/pods/foo/bar/controller.js'
      edit_file 'app/pods/foo/bar/route.js', <<-EOF
        export default Ember.Controller.extend({
          exampleAction() {
            let controller = this.controllerFor('foo.bar')
          }
        });
      EOF
      vim.search 'controllerFor'

      vim.normal 'gf'

      expect(current_file).to eq 'app/pods/foo/bar/controller.js'
    end

    specify "finding a partial template" do
      touch_file 'app/templates/partials/foo-bar/baz.hbs'
      edit_file 'app/templates/example.hbs', <<-EOF
        {{partial "partials/foo-bar/baz"}}
      EOF
      vim.search 'partial'

      vim.normal 'gf'

      expect(current_file).to eq 'app/templates/partials/foo-bar/baz.hbs'
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

    specify "finding a component without a template file" do
      touch_file 'app/components/foo/bar-baz/component.js'
      edit_file 'app/templates/example.hbs', <<-EOF
        <p>
          {{foo/bar-baz param1=something}}
        </p>
      EOF
      vim.search 'foo/bar-baz'

      vim.normal 'gf'

      expect(current_file).to eq 'app/components/foo/bar-baz/component.js'
    end

    specify "finding a component within a pod structure" do
      touch_file 'app/pods/foo/bar-baz/template.hbs'
      edit_file 'app/templates/example.hbs', <<-EOF
        <p>
          {{foo/bar-baz param1=something}}
        </p>
      EOF
      vim.search 'foo/bar-baz'

      vim.normal 'gf'

      expect(current_file).to eq 'app/pods/foo/bar-baz/template.hbs'
    end

    specify "finding a component with block expression" do
      touch_file 'app/components/foo/bar-baz/template.hbs'
      edit_file 'app/templates/example.hbs', <<-EOF
      <p>
        {{#foo/bar-baz param1=something}}
          <p>Foo Bar</p>
        {{/foo/bar-baz}}
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

    specify "finding a controller property" do
      edit_file 'app/controllers/foo.js', <<-EOF
        export default Ember.Controller.extend({
          showSomething: true
        });
      EOF
      edit_file 'app/templates/foo.hbs', <<-EOF
        {{#if showSomething}}
          <div>Something</div>
        {{/if}}
      EOF
      vim.search 'showSomething'

      vim.normal 'gf'

      expect(current_file).to eq 'app/controllers/foo.js'
      expect(current_line.strip).to eq 'showSomething: true'
    end

    specify "finding a component property" do
      edit_file 'app/components/foo/bar-baz/component.js', <<-EOF
        export default Ember.Component.extend({
          showSomething: true
        });
      EOF
      edit_file 'app/components/foo/bar-baz/template.hbs', <<-EOF
        {{#if showSomething}}
          <div>Something</div>
        {{/if}}
      EOF
      vim.search 'showSomething'

      vim.normal 'gf'

      expect(current_file).to eq 'app/components/foo/bar-baz/component.js'
      expect(current_line.strip).to eq 'showSomething: true'
    end

    specify "finding an explicit layoutName" do
      touch_file 'app/templates/some/template/name.hbs'
      edit_file 'app/controllers/example.js', <<-EOF
        export default Ember.Controller.extend({
          layoutName: 'some/template/name'
        });
      EOF
      vim.search 'layoutName'

      vim.normal 'gf'

      expect(current_file).to eq 'app/templates/some/template/name.hbs'
    end

    specify "finding an explicit templateName" do
      touch_file 'app/templates/some/template/name.hbs'
      edit_file 'app/controllers/example.js', <<-EOF
        export default Ember.Controller.extend({
          templateName: 'some/template/name'
        });
      EOF
      vim.search 'templateName'

      vim.normal 'gf'

      expect(current_file).to eq 'app/templates/some/template/name.hbs'
    end

    describe "finding an injected service" do
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

      it "finds a service from its getter" do
        vim.search 'this.get(\'\zsexampleService.'
        vim.normal 'gf'
        expect(current_file).to eq 'app/services/example-service.js'
      end
    end

    describe "finding an injected controller" do
      before :each do
        touch_file 'app/controllers/example.js'
        edit_file 'app/controllers/other.js', <<-EOF
          export default Ember.Controller.extend({
            exampleController: Ember.inject.controller('example')
          });

          beforeModel: function() {
            this.get('exampleController.exampleProperty').doSomething();
          }
        EOF
      end

      it "finds a controller from its inject() line" do
        vim.search 'exampleController: Ember.inject.controller'
        vim.normal 'gf'
        expect(current_file).to eq 'app/controllers/example.js'
      end

      it "finds a controller from its getter" do
        vim.search 'this.get(\'\zsexampleController.'
        vim.normal 'gf'
        expect(current_file).to eq 'app/controllers/example.js'
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
    specify "finding an import" do
      touch_file 'app/stuff.coffee'
      edit_file 'app/foo/bar/baz.coffee', <<-EOF
        `import stuff from '../../stuff';`
      EOF
      vim.search 'stuff\''

      vim.normal 'gf'

      expect(current_file).to eq 'app/stuff.coffee'
    end

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

    specify "finding a route with an index.coffee file" do
      touch_file 'app/routes/foo/bar-baz/index.coffee'
      edit_file 'app/router.coffee', <<-EOF
        @route 'foo', ->
          @route 'bar-baz'
      EOF
      vim.search 'bar-baz'

      vim.normal 'gf'

      expect(current_file).to eq 'app/routes/foo/bar-baz/index.coffee'
    end

    specify "finding a controller" do
      touch_file 'app/controllers/foo/bar.coffee'
      edit_file 'app/routes/baz.coffee', <<-EOF
        exampleAction: ->
          let controller = @controllerFor('foo.bar')
      EOF
      vim.search 'controllerFor'

      vim.normal 'gf'

      expect(current_file).to eq 'app/controllers/foo/bar.coffee'
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
