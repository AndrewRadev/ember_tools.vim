require 'spec_helper'

describe ":Inline" do
  describe "const unpacking" do
    specify "deletes a const line if nothing is left of it after inlining" do
      edit_file 'test.js', <<-EOF
        const { Controller } = Ember;

        export default Controller.extend({});
      EOF

      vim.search 'const { \zsController'
      vim.command 'Inline'
      vim.write

      expect_file_contents current_file, <<-EOF
        export default Ember.Controller.extend({});
      EOF
    end

    specify "deletes an const line with another const line following" do
      edit_file 'test.js', <<-EOF
        const { Controller } = Ember;
        const { foo } = bar;

        export default Controller.extend({});
      EOF

      vim.search 'const { \zsController'
      vim.command 'Inline'
      vim.write

      expect_file_contents current_file, <<-EOF
        const { foo } = bar;

        export default Ember.Controller.extend({});
      EOF
    end

    specify "inlines entries from the beginning" do
      edit_file 'test.js', <<-EOF
        import Ember from 'ember';

        const { computed, Controller, isPresent } = Ember;

        export default Controller.extend({
          foo: Ember.computed.equal('bar', 'baz')
        });
      EOF

      vim.search 'const.*\zscomputed'
      vim.command 'Inline'
      vim.write

      expect_file_contents current_file, <<-EOF
        import Ember from 'ember';

        const { Controller, isPresent } = Ember;

        export default Controller.extend({
          foo: Ember.computed.equal('bar', 'baz')
        });
      EOF
    end

    specify "inlines entries in the middle" do
      edit_file 'test.js', <<-EOF
        import Ember from 'ember';

        const { computed, Controller, isPresent } = Ember;

        export default Controller.extend({
          foo: Ember.computed.equal('bar', 'baz')
        });
      EOF

      vim.search 'const.*\zsController'
      vim.command 'Inline'
      vim.write

      expect_file_contents current_file, <<-EOF
        import Ember from 'ember';

        const { computed, isPresent } = Ember;

        export default Ember.Controller.extend({
          foo: Ember.computed.equal('bar', 'baz')
        });
      EOF
    end

    specify "inlines entries at the end" do
      edit_file 'test.js', <<-EOF
        import Ember from 'ember';

        const { computed, Controller, isPresent } = Ember;

        export default Controller.extend({
          foo: Ember.computed.equal('bar', 'baz')
        });
      EOF

      vim.search 'const.*\zsisPresent'
      vim.command 'Inline'
      vim.write

      expect_file_contents current_file, <<-EOF
        import Ember from 'ember';

        const { computed, Controller } = Ember;

        export default Controller.extend({
          foo: Ember.computed.equal('bar', 'baz')
        });
      EOF
    end
  end
end
