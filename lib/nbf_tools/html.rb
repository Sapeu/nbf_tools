# frozen_string_literal: true

module NbfTools
  class HTML
    CONTENT_FORMAT = "<!DOCTYPE NETSCAPE-Bookmark-file-1>\n<!-- This is an automatically generated file.\n     It will be read and overwritten.\n     DO NOT EDIT! -->\n<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=UTF-8\">\n<TITLE>Bookmarks</TITLE>\n<H1>Bookmarks</H1>\n<DL><p>\n%{content}\n</DL><p>"
    LINK_FORMAT = "%{indent}<DT><A %{attributes}>%{text}</A>"
    FOLDER_FORMAT = "%{indent}<DT><H3 %{attributes}>%{text}</H3>\n%{indent}<DL><p>\n%{items}\n%{indent}</DL><p>"

    def initialize(data)
      @data = data
    end

    def to_s
      sprintf(CONTENT_FORMAT, content: data_html)
    end

    def generate_attributes(element, *except_keys)
      element.except(*except_keys).transform_keys(&:upcase).map { |k, v| "#{k}=\"#{v}\"" }.join(" ")
    end

    def data_html(data = @data)
      return if data.nil?
      data.map do |e|
        case e["type"]
        when NbfTools.config.link_type_text
          link_html(e)
        when NbfTools.config.folder_type_text
          folder_html(e)
        end
      end.join("\n")
    end

    def link_html(item)
      indent = "\t" * (item["path"].count("/") + 1)
      attributes = generate_attributes(item, "path", "text", "type")
      text = item["text"]
      sprintf(LINK_FORMAT, indent: indent, attributes: attributes, text: text)
    end

    def folder_html(folder)
      indent = "\t" * folder["path"].count("/")
      attributes = generate_attributes(folder, "path", "text", "type", "items")
      text = folder["text"]
      items = data_html(folder["items"])
      sprintf(FOLDER_FORMAT, indent: indent, attributes: attributes, text: text, items: items)
    end
  end
end
