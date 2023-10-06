# frozen_string_literal: true

require_relative "nbf_tools/configuration"
require_relative "nbf_tools/html"
require_relative "nbf_tools/merge"
require_relative "nbf_tools/parse"
require_relative "nbf_tools/version"

module NbfTools
  class Error < StandardError; end
  # Your code goes here...

  class << self
    def config
      return @config if defined?(@config)

      @config = Configuration.new
      @config.personal_toolbar_folder_text = "personal toolbar"
      @config.link_type_text = "link"
      @config.folder_type_text = "folder"

      @config
    end

    def configure(&block)
      config.instance_exec(&block)
    end

    def parse(file)
      Parse.new(file).parse
    end

    def parse_files_in_one(*files)
      data = files.map { |file| parse(file) }
      return data[0] if files.size < 2
      Merge.new(data).to_a
    end

    def parse_files_in_one_html(*files)
      return File.read(files[0]) if files.size < 2
      data = parse_files_in_one(*files)
      HTML.new(data).to_s
    end
  end
end
