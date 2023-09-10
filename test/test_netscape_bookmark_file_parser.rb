# frozen_string_literal: true

require "test_helper"

class TestNetscapeBookmarkFileParser < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::NetscapeBookmarkFileParser::VERSION
  end

  # def test_it_does_something_useful
  #   assert false
  # end

  def test_parse
    refute_empty ::NetscapeBookmarkFileParser.parse("test/c.html")
  end

  def test_parse_bookmark
    p ::NetscapeBookmarkFileParser.parse("test/c.html")
  end
end
