require 'spec_helper'

describe ":Extract" do
  specify "extract a template to a component" do
    edit_file 'app/templates/example-template.emblem', <<-EOF
      .first
        .second
          .third
    EOF

    vim.search 'second'
    vim.normal 'Vj:Extract example-component<cr>'

    # force sync
    vim.command('echo')

    expect(File.exists?('app/components/example-component/component.coffee')).to be_truthy
    expect(File.exists?('app/components/example-component/template.emblem')).to be_truthy

    expect(current_file).to eq 'app/components/example-component/template.emblem'

    expect_file_contents current_file, <<-EOF
      .second
        .third
    EOF
    expect_file_contents 'app/templates/example-template.emblem', <<-EOF
      .first
        = example-component
    EOF
  end
end
