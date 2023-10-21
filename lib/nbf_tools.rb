# frozen_string_literal: true

require_relative "nbf_tools/html"
require_relative "nbf_tools/merge"
require_relative "nbf_tools/parse"
require_relative "nbf_tools/options"
require_relative "nbf_tools/version"

require "json"

module NbfTools
  class Error < StandardError; end

  class << self

    # parse file
    # options: `{personal_toolbar_folder_text: "some string"}`, is optional
    def parse(file, **options)
      Parse.new(**options).parse(file)
    end

    # merge and parse multiple files
    # options: `{personal_toolbar_folder_text: "some string"}`, is optional
    def parse_files_to_one(*files, **options)
      parse_tool = Parse.new(**options)
      data = files.map { |file| parse_tool.parse(file) }
      return data[0] if files.size < 2
      Merge.new(data).to_a
    end

    # merge multiple files into one html string
    # options: `{personal_toolbar_folder_text: "some string"}`, is optional
    def merge_files_to_one_html(*files, **options)
      return File.read(files[0]) if files.size < 2
      data = parse_files_to_one(*files, **options)
      HTML.new(data).to_s
    end

    # parse and merge operate with options
    # options: `{files: [], personal_toolbar_folder_text: [], out_format: []}`
    # `:files` must present
    # `:personal_toolbar_folder_text` is optional
    # if `:out_format` is `"json"` return json format else retrun return html format
    def operate_with_options(opts)
      opts[:out_format] ||= []
      opts[:personal_toolbar_folder_text] = [opts[:personal_toolbar_folder_text]] if opts[:personal_toolbar_folder_text].is_a?(Array)
      if opts[:out_format].join(" ") == "json"
        parse_files_to_one(*opts[:files], personal_toolbar_folder_text: opts[:personal_toolbar_folder_text].join(" ")).to_json
      else
        merge_files_to_one_html(*opts[:files], personal_toolbar_folder_text: opts[:personal_toolbar_folder_text].join(" "))
      end
    end
  end
end
