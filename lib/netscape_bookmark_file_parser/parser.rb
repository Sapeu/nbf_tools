# frozen_string_literal: true
require "nokogiri"
module NetscapeBookmarkFileParser

  def self.parse(file)
    Parser.new(file).parse
  end

  class Parser
    def initialize file
      if file.is_a?(File)
        @document = Nokogiri::HTML(file)
      elsif File.file?(file)
        @document = Nokogiri::HTML(File.open(file))
      else
        @document = Nokogiri::HTML(file)
      end
    end

    def parse
      parse_node_children(@document.xpath('/html/body/dl').first)
    end

    def parse_node_children(node)
      node.children.each_with_object([]) do |c, items|
        case c.node_name
        when 'dt'
          items.push *parse_node_children(c)
        when 'a'
          bookmark = Link.new c.attributes, c.text, c["href"]
          items.push bookmark
        when 'h3'
          folder = Folder.new c.attributes, c.text
          items.push folder
        when 'dl'
          folder = items.select{|e| e.is_a?(Folder)}.last
          folder.nil? ? items.push(*parse_node_children(c)) : folder.items = parse_node_children(c)
        end
      end
    end

  end
end
