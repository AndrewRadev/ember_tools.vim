require 'fileutils'
require 'vimrunner'
require 'vimrunner/rspec'
require_relative './support/vim'

Vimrunner::RSpec.configure do |config|
  config.reuse_server = true

  plugin_path = File.expand_path('.')

  config.start_vim do
    vim = Vimrunner.start_gvim
    vim.add_plugin(plugin_path, 'plugin/ember_tools.vim')

    # bootstrap filetypes
    vim.command 'autocmd BufNewFile,BufRead *.coffee set filetype=coffee'
    vim.command 'autocmd BufNewFile,BufRead *.emblem set filetype=emblem'
    vim.command 'autocmd BufNewFile,BufRead *.hbs set filetype=handlebars'

    vim.command 'autocmd FileType * set expandtab tabstop=2 shiftwidth=2'

    vim
  end
end

RSpec.configure do |config|
  config.include Support::Vim

  config.before :each do
    touch_file 'ember-cli-build.js'
  end
end
