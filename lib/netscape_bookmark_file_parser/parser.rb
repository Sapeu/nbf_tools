# frozen_string_literal: true
require "nokogiri"
module NetscapeBookmarkFileParser
  LINKE_TYPE = 'link'
  FOLDER_TYPE = 'folder'

  class << self
    def merge(*files)
      data = parse(*files)
      link_map = {}
      folder_map = {}
      data.each do |file_data|
        convert_folder_and_link_map(file_data, link_map, folder_map)
      end
      (link_map.values + folder_map.values).sort{|a, b| a['path'] <=> b['path']}
    end

    def convert_folder_and_link_map(data, link_map, folder_map)
      data.map do |e|
        case e['type']
        when LINKE_TYPE
          choose_latest_element(link_map, e['href'], e)
        when FOLDER_TYPE
          choose_latest_element(link_map, e['text'], e)
          folder_map[e['text']] = e.except('items')
          convert_folder_and_link_map(e['items'], link_map, folder_map)
        end
      end
    end

    def choose_latest_element(data_map, key, new_element)
      if data_map.value?(key)
        old_e = data_map[key]
        if [new_element['add_data'].to_i, new_element['last_modified'].to_i].max > [old_e['add_data'].to_i, old_e['last_modified'].to_i].max
          data_map[key] = new_element
        end
      else
        data_map[key] = new_element
      end
    end

    def parse(*files)
      files.map{|file| NetscapeBookmarkFileParser::Parser.new(file).parse }
    end
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
      parse_node_children(@document.xpath('/html/body/dl').first, Pathname.new('/'))
    end

    def parse_node_children(node, path)
      node.children.each_with_object([]) do |c, items|
        case c.node_name
        when 'dt'
          items.push *parse_node_children(c, path)
        when 'a'
          bookmark = c.to_h.merge('text' => c.text, 'type' => LINKE_TYPE, 'path' => path.to_s)
          items.push bookmark
        when 'h3'
          folder_name = c.text
          folder_name = '' if c['personal_toolbar_folder'] == 'true'
          folder = c.to_h.merge('text' => folder_name, 'type' => FOLDER_TYPE, 'path' => path.to_s, 'items' => [])
          items.push folder
        when 'dl'
          folder = items.select{|e| e['type'] == 'folder' }.last
          folder.nil? ? items.push(*parse_node_children(c), path) : folder['items'] = parse_node_children(c, path + folder['text'])
        end
      end
    end

  end
end
