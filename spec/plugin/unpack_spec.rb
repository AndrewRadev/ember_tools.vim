require 'spec_helper'

describe ":Unpack" do
  specify "creates a const line if there is none, at the top of the file" do
    edit_file 'test.js', <<-EOF
      export default Ember.Controller.extend({});
    EOF

    vim.search 'Ember\.Controller'
    vim.command 'Unpack'
    vim.write

    expect_file_contents current_file, <<-EOF
      const { Controller } = Ember;

      export default Controller.extend({});
    EOF
  end

  specify "creates a const line if there is none, after the import lines" do
    edit_file 'test.js', <<-EOF
      import Ember from 'ember';

      export default Ember.Controller.extend({});
    EOF

    vim.search 'Ember\.Controller'
    vim.command 'Unpack'
    vim.write

    expect_file_contents current_file, <<-EOF
      import Ember from 'ember';

      const { Controller } = Ember;

      export default Controller.extend({});
    EOF
  end

  specify "adds entries to the const line if it exists" do
    edit_file 'test.js', <<-EOF
      import Ember from 'ember';

      const { Controller } = Ember;

      export default Controller.extend({
        foo: Ember.computed.equal('bar', 'baz')
      });
    EOF

    vim.search 'Ember\.computed'
    vim.command 'Unpack'
    vim.write

    expect_file_contents current_file, <<-EOF
      import Ember from 'ember';

      const { Controller, computed } = Ember;

      export default Controller.extend({
        foo: computed.equal('bar', 'baz')
      });
    EOF
  end

  specify "adds a new const line for nested unpacking" do
    edit_file 'test.js', <<-EOF
      import Ember from 'ember';

      const { Controller } = Ember;

      export default Controller.extend({});
    EOF

    vim.search 'Controller\.extend'
    vim.command 'Unpack'
    vim.write

    expect_file_contents current_file, <<-EOF
      import Ember from 'ember';

      const { Controller } = Ember;
      const { extend } = Controller;

      export default extend({});
    EOF
  end
end
