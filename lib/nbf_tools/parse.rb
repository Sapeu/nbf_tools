# frozen_string_literal: true

require "nokogiri"
module NbfTools
  class Parse
    def initialize file
      @document = Nokogiri::HTML(File.open(file))
    end

    def parse
      parse_node_children(@document.xpath("/html/body/dl").first, Pathname.new("/"))
    end

    def parse_node_children(node, path)
      node.children.each_with_object([]) do |c, items|
        case c.node_name
        when "dt"
          items.push(*parse_node_children(c, path))
        when "a"
          bookmark = c.to_h.merge("text" => c.text, "type" => NbfTools.config.link_type_text, "path" => path.to_s)
          items.push bookmark
        when "h3"
          folder_name = c.text
          folder_name = NbfTools.config.personal_toolbar_folder_text if c["personal_toolbar_folder"] == "true"
          folder = c.to_h.merge("text" => folder_name, "type" => NbfTools.config.folder_type_text, "path" => (path + folder_name).to_s, "items" => [])
          items.push folder
        when "dl"
          folder = items.reverse.find { |e| e["type"] == "folder" }
          folder.nil? ? items.push(*parse_node_children(c), path) : folder["items"] = parse_node_children(c, path + folder["text"])
        end
      end
    end
  end
end
