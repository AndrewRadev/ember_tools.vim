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
    touch_file 'app/components/foo/bar-baz/component.coffee'
    edit_file 'app/templates/example.emblem', <<-EOF
      p
        = foo/bar-baz param1=something
    EOF
    vim.search 'foo/bar-baz'

    vim.normal 'gf'

    expect(current_file).to eq 'app/components/foo/bar-baz/component.coffee'
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
end
