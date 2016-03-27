require 'spec_helper'

describe "gf mapping" do
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

  describe "finding a service" do
    before :each do
      touch_file 'app/services/example-service.coffee'
      edit_file 'app/routes/example-route.coffee', <<-EOF
        `import Ember from 'ember';`

        route = Ember.Route.extend
          exampleService: Ember.inject.service()

        beforeModel: ->
          @get('exampleService.exampleProperty').doSomething()

        `export default route`
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
        `import Ember from 'ember';`

        route = Ember.Route.extend
          model: ->
            @store.createRecord('example-model')
            @modelFor('example-model')

        model = Ember.Model.extend
          otherModel: DS.belongsTo("otherModel", async: false)
          otherModel: DS.hasMany("otherModel", async: true)

        `export default route`
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
