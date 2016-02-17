require 'fileutils'

module Support
  module Vim
    def touch_file(filename)
      if !File.exists?(filename)
        FileUtils.mkdir_p(File.dirname(filename))
        write_file(filename, '')
      end
    end

    def edit_file(filename, contents = nil)
      FileUtils.mkdir_p(File.dirname(filename))

      if contents
        write_file(filename, contents)
      else
        touch_file(filename)
      end

      vim.edit!(filename)
    end

    def current_file
      vim.command('echo expand("%")')
    end
  end
end
