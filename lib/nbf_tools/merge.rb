# frozen_string_literal: true

module NbfTools
  class Merge
    def initialize(data)
      @data = data
      @link_map = {}
      @folder_map = {}
    end

    def to_a
      @data.each do |file_data|
        flat_folder_and_link_map(file_data, @link_map, @folder_map)
      end

      @link_map.values.each do |e|
        folder = @folder_map[e["path"]]
        next if folder.nil?
        folder["items"] ||= []
        folder["items"] << e
        @folder_map[e["path"]] = folder
      end

      @folder_map.values.each do |e|
        parent_path = e["path"].split("/")[0..-2].join("/")
        folder = @folder_map[parent_path]
        next if folder.nil?
        folder["items"] ||= []
        folder["items"] << e
        @folder_map[parent_path] = folder
      end
      @folder_map.values.select { |e| e["path"].count("/") < 2 } + @link_map.values.select { |e| e["path"] == "/" }
    end

    def flat_folder_and_link_map(data, link_map, folder_map)
      data.map do |e|
        case e["type"]
        when NbfTools.config.link_type_text
          choose_latest_element(link_map, "href", e)
        when NbfTools.config.folder_type_text
          choose_latest_element(folder_map, "path", e)
          flat_folder_and_link_map(e["items"], link_map, folder_map)
        end
      end
    end

    def choose_latest_element(data_map, key, new_element)
      if data_map.key?(new_element[key])
        old_e = data_map[new_element[key]]
        if [new_element["add_date"].to_i, new_element["last_modified"].to_i].max > [old_e["add_date"].to_i, old_e["last_modified"].to_i].max
          data_map[new_element[key]] = new_element.except("items")
        end
      else
        data_map[new_element[key]] = new_element.except("items")
      end
    end
  end
end
