require 'spec_helper'

describe ":Extract" do
  after :each do
    # remove extra splits
    vim.command('only')
  end

  describe "javascript/hbs" do
    specify "extract a template to a component" do
      edit_file 'app/templates/example-template.hbs', <<-EOF
        <div class="first">
          <div class="second">
            <div class="third">
            </div>
          </div>
        </div>
      EOF

      vim.search 'second'
      vim.normal 'V3j:Extract example-component<cr>'

      # force sync
      vim.command('echo')

      expect(File.exists?('app/components/example-component/component.js')).to be_truthy
      expect(File.exists?('app/components/example-component/template.hbs')).to be_truthy

      expect(current_file).to eq 'app/components/example-component/template.hbs'

      expect_file_contents current_file, <<-EOF
        <div class="second">
          <div class="third">
          </div>
        </div>
      EOF
      expect_file_contents 'app/templates/example-template.hbs', <<-EOF
        <div class="first">
          {{example-component}}
        </div>
      EOF
    end
  end

  describe "coffee/emblem" do
    around :each do |example|
      vim.command('let g:ember_tools_default_logic_filetype = "coffee"')
      example.run
      vim.command('let g:ember_tools_default_logic_filetype = "javascript"')
    end

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
end
