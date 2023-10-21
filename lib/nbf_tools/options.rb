# frozen_string_literal: true

module NbfTools
  class Options
    COMMAND_HELP_TEXT = <<~TEXT.chomp
      usage: nbf_tools [options]
          -f, --files                         NETSCAPE Bookmark files, delimit by space
          -o, --out-format                    output parse result format (default: html), options: json, html
          -t, --personal-toolbar-folder-text  custom personal toolbar folder text

      other options:
          -h, --help                      print help
          -v, --version                   print version
    TEXT

    def initialize(argv)
      @argv = argv
    end

    def parse
      opts = {unknown_option: [], files: [], personal_toolbar_folder_text: [], out_format: []}
      option_key = :unknown_option

      @argv.each do |e|
        case e
        when "-h", "--help"
          puts COMMAND_HELP_TEXT
          exit
        when "-v", "--version"
          puts NbfTools::VERSION
          exit
        when "-f", "--files"
          option_key = :files
        when "-o", "--out_format"
          option_key = :out_format
        when "-t", "--personal_toolbar_folder_text"
          option_key = :personal_toolbar_folder_text
        when /\A-.+\z/
          option_key = :unknown_option
          warn "unknown option #{e}"
        else
          opts[option_key] << e
        end
      end

      opts
    end
  end
end
