# frozen_string_literal: true

module NetscapeBookmarkFileParser
  class Link
    attr_accessor :attributes, :text, :href
    def initialize(attributes, text, href)
      @attributes = attributes
      @text = text
      @href = href
    end
  end
end
