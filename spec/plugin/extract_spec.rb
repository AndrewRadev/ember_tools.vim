require 'spec_helper'

describe ":Extract" do
  after :each do
    # remove extra splits
    vim.command('only')
    # reset to default settings
    vim.command('let g:ember_tools_extract_behaviour = "separate-template"')
  end

  describe "javascript/hbs" do
    def perform_extract
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
    end

    specify "extract a template to a component" do
      perform_extract

      expect(File.exists?('app/components/example-component.js')).to be_truthy
      expect(File.exists?('app/templates/components/example-component.hbs')).to be_truthy

      expect(current_file).to eq 'app/templates/components/example-component.hbs'

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

    specify "extract a template to a component directory" do
      vim.command('let g:ember_tools_extract_behaviour = "component-dir"')

      perform_extract

      expect(File.exists?('app/components/example-component/component.js')).to be_truthy
      expect(File.exists?('app/components/example-component/template.hbs')).to be_truthy

      expect(current_file).to eq 'app/components/example-component/template.hbs'
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

      expect(File.exists?('app/components/example-component.coffee')).to be_truthy
      expect(File.exists?('app/templates/components/example-component.emblem')).to be_truthy

      expect(current_file).to eq 'app/templates/components/example-component.emblem'

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
