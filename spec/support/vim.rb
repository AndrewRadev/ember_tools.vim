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

    def expect_file_contents(filename, string)
      string = normalize_string_indent(string)
      expect(IO.read(filename).strip).to eq(string)
    end
  end
end
