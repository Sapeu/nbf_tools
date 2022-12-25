# frozen_string_literal: true

module NetscapeBookmarkFileParser
  class Folder
    attr_accessor :attributes, :text, :items

    def initialize(attributes, text)
      @attributes = attributes
      @text = text
      @items = []
    end
  end
end
