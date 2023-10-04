# frozen_string_literal: true

require "erb"
require "json"
require_relative "netscape_bookmark_file_parser/version"
require_relative "netscape_bookmark_file_parser/parser"
require_relative "netscape_bookmark_file_parser/configuration"

module NetscapeBookmarkFileParser
  class Error < StandardError; end
  # Your code goes here...

  class << self
    def config
      return @config if defined?(@config)

      @config = Configuration.new
      @config.personal_toolbar_folder_text = "personal toolbar"
      @config.link_type_text = "link"
      @config.folder_type_text = "folder"
      @config.body_template = "<!DOCTYPE NETSCAPE-Bookmark-file-1>\n<!-- This is an automatically generated file.It will be read and overwritten.DO NOT EDIT! -->\n<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=UTF-8\">\n<TITLE>Bookmarks</TITLE>\n<H1>Bookmarks</H1>\n<DL><p>\n<%= items %>\n</DL><p>\n"
      @config.link_template = "<%= prefix %><%= \"\t\" * element_indent %><DT><A <%= attributes %>><%= text %></A>\n"
      @config.folder_template = "<%= prefix %><%= \"\t\" * element_indent %><DT><H3 <%= attributes %>><%= text %></H3>\n<%= \"\t\" * (element_indent + 1) %><DL><p>\n"
      @config.nbf_template_path = "lib/netscape_bookmark_file_parser/templates/nbf.rhtml"
      @config
    end

    def configure(&block)
      config.instance_exec(&block)
    end

    def to_array(*files)
      data = parse(*files)
      link_map = {}
      folder_map = {}

      data.each do |file_data|
        flat_folder_and_link_map(file_data, link_map, folder_map)
      end

      link_map.values.each do |e|
        folder = folder_map[e["path"]]
        next if folder.nil?
        folder["items"] ||= []
        folder["items"] << e
        folder_map[e["path"]] = folder
      end

      folder_map.values.each do |e|
        parent_path = e["path"].split("/")[0..-2].join("/")
        folder = folder_map[parent_path]
        next if folder.nil?
        folder["items"] ||= []
        folder["items"] << e
        folder_map[parent_path] = folder
      end
      folder_map.values.select { |e| e["path"].count("/") < 2 } + link_map.values.select { |e| e["path"] == "/" }
    end

    def flat_folder_and_link_map(data, link_map, folder_map)
      data.map do |e|
        case e["type"]
        when config.link_type_text
          choose_latest_element(link_map, "href", e)
        when config.folder_type_text
          choose_latest_element(folder_map, "path", e)
          flat_folder_and_link_map(e["items"], link_map, folder_map)
        end
      end
    end

    def choose_latest_element(data_map, key, new_element)
      if data_map.value?(new_element[key])
        old_e = data_map[new_element[key]]
        if [new_element["add_data"].to_i, new_element["last_modified"].to_i].max > [old_e["add_data"].to_i, old_e["last_modified"].to_i].max
          data_map[new_element[key]] = new_element.except("items")
        end
      else
        data_map[new_element[key]] = new_element.except("items")
      end
    end

    def parse(*files)
      files.map { |file| Parser.new(file).parse }
    end

    def to_html(*files)
      data = to_array(*files)
      ERB.new(File.read(config.nbf_template_path)).result(binding)
    end

    def count_path_indent_number(path)
      path.split("/").size
    end

    def generate_attributes(element, *except_keys)
      element.except(*except_keys).transform_keys(&:upcase).map { |k, v| "#{k}=\"#{v}\"" }.join(" ")
    end

    def generate_prefix(start_indent, end_indent)
      return unless start_indent > end_indent
      close_idents = []
      (start_indent - 1).downto(end_indent) do |indent|
        close_idents << "\t" * indent + "</DL><p>\n"
      end
      close_idents.join
    end

    def render_folder_and_link_map(data)
      last_indent = 1

      data.map do |e|
        case e["type"]
        when config.link_type_text
          element_indent = count_path_indent_number(e["path"])
          attributes = generate_attributes(e, "path", "text", "type")
          text = e["text"]
          prefix = generate_prefix(element_indent, last_indent)
          last_indent = element_indent
          ERB.new(config.link_template).result(binding)
        when config.folder_type_text
          element_indent = count_path_indent_number(e["path"])
          attributes = generate_attributes(e, "path", "text", "type", "items")
          text = e["text"]
          prefix = generate_prefix(element_indent, last_indent)
          last_indent = element_indent + 1
          ERB.new(config.folder_template).result(binding)
        end
      end
    end

    def write(file_path, *files)
      case File.extname(file_path)
      when ".json"
        IO.write(file_path, to_array(*files).to_json)
      else
        return IO.write(file_path, to_html(*files)) if files.size > 1

        if files.size < 2
          if file.is_a?(File)
            IO.write(file_path, file)
          elsif File.file?(file)
            IO.write(file_path, File.open(file))
          else
            IO.write(file_path, file)
          end
        end

      end
    end
  end
end
