# frozen_string_literal: true

require "nokogiri"
require_relative "type"

module NbfTools
  class Parse
    def initialize options = {}
      @options = options
    end

    def parse file
      @document = Nokogiri::HTML(File.open(file))
      parse_node_children(@document.xpath("/html/body/dl").first, Pathname.new("/"))
    end

    def parse_node_children(node, path)
      node.children.each_with_object([]) do |c, items|
        case c.node_name
        when "dt"
          items.push(*parse_node_children(c, path))
        when "a"
          bookmark = c.to_h.merge("text" => c.text, "type" => NbfTools::Type::LINK, "path" => path.to_s)
          items.push bookmark
        when "h3"
          text = folder_text(c)
          folder = c.to_h.merge("text" => text, "type" => NbfTools::Type::FOLDER, "path" => (path + text).to_s, "items" => [])
          items.push folder
        when "dl"
          folder = items.reverse.find { |e| e["type"] == "folder" }
          folder.nil? ? items.push(*parse_node_children(c), path) : folder["items"] = parse_node_children(c, path + folder["text"])
        end
      end
    end

    def folder_text item
      return item.text unless item["personal_toolbar_folder"] == "true"
      if @options[:personal_toolbar_folder_text].to_s.empty?
        @options[:personal_toolbar_folder_text] = item.text
      else
        @options[:personal_toolbar_folder_text]
      end
    end
  end
end
