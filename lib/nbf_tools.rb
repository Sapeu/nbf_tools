# frozen_string_literal: true

require_relative "nbf_tools/html"
require_relative "nbf_tools/merge"
require_relative "nbf_tools/parse"
require_relative "nbf_tools/version"

module NbfTools
  class Error < StandardError; end

  class << self
    def parse(file, **options)
      Parse.new(**options).parse(file)
    end

    def parse_files_to_one(*files, **options)
      parse_tool = Parse.new(**options)
      data = files.map { |file| parse_tool.parse(file) }
      return data[0] if files.size < 2
      Merge.new(data).to_a
    end

    def merge_files_to_one_html(*files, **custom_options)
      return File.read(files[0]) if files.size < 2
      data = parse_files_to_one(*files)
      HTML.new(data).to_s
    end
  end
end
