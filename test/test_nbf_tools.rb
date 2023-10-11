# frozen_string_literal: true

require "test_helper"
require "json"

class TestNbfTools < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::NbfTools::VERSION
  end

  def test_parse
    file_content = <<~HTML.chomp
      <!DOCTYPE NETSCAPE-Bookmark-file-1>
      <!-- This is an automatically generated file.
           It will be read and overwritten.
           DO NOT EDIT! -->
      <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
      <TITLE>Bookmarks</TITLE>
      <H1>Bookmarks</H1>
      <DL><p>
      \t<DT><H3 ADD_DATE="1" LAST_MODIFIED="2" PERSONAL_TOOLBAR_FOLDER="true">书签栏</H3>
      \t<DL><p>
      \t\t<DT><A HREF="https://a" ADD_DATE="3" LAST_MODIFIED="4">A</A>
      \t\t<DT><H3 ADD_DATE="5" LAST_MODIFIED="6">A</H3>
      \t\t<DL><p>
      \t\t\t<DT><A HREF="https://aa" ADD_DATE="7" LAST_MODIFIED="8">AA</A>
      \t\t</DL><p>
      \t</DL><p>
      </DL><p>
    HTML
    IO.write("tmp/test_parse.html", file_content)
    exp = [
      {
        "add_date" => "1",
        "last_modified" => "2",
        "personal_toolbar_folder" => "true",
        "text" => "书签栏",
        "type" => "folder",
        "path" => "/书签栏",
        "items" => [
          {
            "href" => "https://a",
            "add_date" => "3",
            "last_modified" => "4",
            "text" => "A",
            "type" => "link",
            "path" => "/书签栏"
          },
          {
            "add_date" => "5",
            "last_modified" => "6",
            "text" => "A",
            "type" => "folder",
            "path" => "/书签栏/A",
            "items" => [
              {
                "href" => "https://aa",
                "add_date" => "7",
                "last_modified" => "8",
                "text" => "AA",
                "type" => "link",
                "path" => "/书签栏/A"
              }
            ]
          }
        ]
      }
    ]

    custom_folder_text_exp = [
      {
        "add_date" => "1",
        "last_modified" => "2",
        "personal_toolbar_folder" => "true",
        "text" => "custom folder text",
        "type" => "folder",
        "path" => "/custom folder text",
        "items" => [
          {
            "href" => "https://a",
            "add_date" => "3",
            "last_modified" => "4",
            "text" => "A",
            "type" => "link",
            "path" => "/custom folder text"
          },
          {
            "add_date" => "5",
            "last_modified" => "6",
            "text" => "A",
            "type" => "folder",
            "path" => "/custom folder text/A",
            "items" => [
              {
                "href" => "https://aa",
                "add_date" => "7",
                "last_modified" => "8",
                "text" => "AA",
                "type" => "link",
                "path" => "/custom folder text/A"
              }
            ]
          }
        ]
      }
    ]

    assert_equal exp, NbfTools.parse("tmp/test_parse.html")
    assert_equal custom_folder_text_exp, NbfTools.parse("tmp/test_parse.html", personal_toolbar_folder_text: "custom folder text")
  end

  def test_parse_files_to_one
    file_content1 = <<~HTML.chomp
      <!DOCTYPE NETSCAPE-Bookmark-file-1>
      <!-- This is an automatically generated file.
           It will be read and overwritten.
           DO NOT EDIT! -->
      <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
      <TITLE>Bookmarks</TITLE>
      <H1>Bookmarks</H1>
      <DL><p>
      \t<DT><H3 ADD_DATE="1" LAST_MODIFIED="2" PERSONAL_TOOLBAR_FOLDER="true">书签栏</H3>
      \t<DL><p>
      \t\t<DT><A HREF="https://a" ADD_DATE="3" LAST_MODIFIED="4">A</A>
      \t\t<DT><H3 ADD_DATE="5" LAST_MODIFIED="6">A</H3>
      \t\t<DL><p>
      \t\t\t<DT><A HREF="https://aa" ADD_DATE="17" LAST_MODIFIED="18">AA</A>
      \t\t</DL><p>
      \t</DL><p>
      </DL><p>
    HTML
    IO.write("tmp/test_parse_files_to_one1.html", file_content1)
    file_content2 = <<~HTML.chomp
      <!DOCTYPE NETSCAPE-Bookmark-file-1>
      <!-- This is an automatically generated file.
           It will be read and overwritten.
           DO NOT EDIT! -->
      <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
      <TITLE>Bookmarks</TITLE>
      <H1>Bookmarks</H1>
      <DL><p>
      \t<DT><H3 ADD_DATE="1" LAST_MODIFIED="2" PERSONAL_TOOLBAR_FOLDER="true">书签栏</H3>
      \t<DL><p>
      \t\t<DT><A HREF="https://a" ADD_DATE="3" LAST_MODIFIED="4">A</A>
      \t\t<DT><H3 ADD_DATE="5" LAST_MODIFIED="6">A</H3>
      \t\t<DL><p>
      \t\t\t<DT><A HREF="https://ab" ADD_DATE="9" LAST_MODIFIED="10">AB</A>
      \t\t</DL><p>
      \t\t<DT><H3 ADD_DATE="11" LAST_MODIFIED="12">B</H3>
      \t\t<DL><p>
      \t\t\t<DT><A HREF="https://aa" ADD_DATE="13" LAST_MODIFIED="14">AA</A>
      \t\t\t<DT><A HREF="https://bb" ADD_DATE="15" LAST_MODIFIED="16">BB</A>
      \t\t</DL><p>
      \t</DL><p>
      </DL><p>
    HTML
    IO.write("tmp/test_parse_files_to_one2.html", file_content2)
    exp = [
      {
        "add_date" => "1",
        "last_modified" => "2",
        "personal_toolbar_folder" => "true",
        "text" => "书签栏",
        "type" => "folder",
        "path" => "/书签栏",
        "items" => [
          {
            "href" => "https://a",
            "add_date" => "3",
            "last_modified" => "4",
            "text" => "A",
            "type" => "link",
            "path" => "/书签栏"
          },
          {
            "add_date" => "5",
            "last_modified" => "6",
            "text" => "A", "type" => "folder",
            "path" => "/书签栏/A",
            "items" => [
              {
                "href" => "https://aa",
                "add_date" => "17",
                "last_modified" => "18",
                "text" => "AA",
                "type" => "link",
                "path" => "/书签栏/A"
              },
              {
                "href" => "https://ab",
                "add_date" => "9",
                "last_modified" => "10",
                "text" => "AB",
                "type" => "link",
                "path" => "/书签栏/A"
              }
            ]
          },
          {
            "add_date" => "11",
            "last_modified" => "12",
            "text" => "B",
            "type" => "folder",
            "path" => "/书签栏/B",
            "items" => [
              {
                "href" => "https://bb",
                "add_date" => "15",
                "last_modified" => "16",
                "text" => "BB",
                "type" => "link",
                "path" => "/书签栏/B"
              }
            ]
          }
        ]
      }
    ]

    custom_folder_text_exp = [
      {
        "add_date" => "1",
        "last_modified" => "2",
        "personal_toolbar_folder" => "true",
        "text" => "custom folder text 2",
        "type" => "folder",
        "path" => "/custom folder text 2",
        "items" => [
          {
            "href" => "https://a",
            "add_date" => "3",
            "last_modified" => "4",
            "text" => "A",
            "type" => "link",
            "path" => "/custom folder text 2"
          },
          {
            "add_date" => "5",
            "last_modified" => "6",
            "text" => "A", "type" => "folder",
            "path" => "/custom folder text 2/A",
            "items" => [
              {
                "href" => "https://aa",
                "add_date" => "17",
                "last_modified" => "18",
                "text" => "AA",
                "type" => "link",
                "path" => "/custom folder text 2/A"
              },
              {
                "href" => "https://ab",
                "add_date" => "9",
                "last_modified" => "10",
                "text" => "AB",
                "type" => "link",
                "path" => "/custom folder text 2/A"
              }
            ]
          },
          {
            "add_date" => "11",
            "last_modified" => "12",
            "text" => "B",
            "type" => "folder",
            "path" => "/custom folder text 2/B",
            "items" => [
              {
                "href" => "https://bb",
                "add_date" => "15",
                "last_modified" => "16",
                "text" => "BB",
                "type" => "link",
                "path" => "/custom folder text 2/B"
              }
            ]
          }
        ]
      }
    ]
    assert_equal exp, NbfTools.parse_files_to_one("tmp/test_parse_files_to_one1.html", "tmp/test_parse_files_to_one2.html")
    assert_equal custom_folder_text_exp, NbfTools.parse_files_to_one("tmp/test_parse_files_to_one1.html", "tmp/test_parse_files_to_one2.html", personal_toolbar_folder_text: "custom folder text 2")
  end

  def test_html_to_s
    data = [
      {
        "add_date" => "1",
        "last_modified" => "2",
        "personal_toolbar_folder" => "true",
        "text" => "书签栏",
        "type" => "folder",
        "path" => "/书签栏",
        "items" => [
          {
            "href" => "https://a",
            "add_date" => "3",
            "last_modified" => "4",
            "text" => "A",
            "type" => "link",
            "path" => "/书签栏"
          },
          {
            "add_date" => "5",
            "last_modified" => "6",
            "text" => "A",
            "type" => "folder",
            "path" => "/书签栏/A",
            "items" => [
              {
                "href" => "https://aa",
                "add_date" => "7",
                "last_modified" => "8",
                "text" => "AA",
                "type" => "link",
                "path" => "/书签栏/A"
              }
            ]
          }
        ]
      }
    ]
    exp = <<~HTML.chomp
      <!DOCTYPE NETSCAPE-Bookmark-file-1>
      <!-- This is an automatically generated file.
           It will be read and overwritten.
           DO NOT EDIT! -->
      <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
      <TITLE>Bookmarks</TITLE>
      <H1>Bookmarks</H1>
      <DL><p>
      \t<DT><H3 ADD_DATE="1" LAST_MODIFIED="2" PERSONAL_TOOLBAR_FOLDER="true">书签栏</H3>
      \t<DL><p>
      \t\t<DT><A HREF="https://a" ADD_DATE="3" LAST_MODIFIED="4">A</A>
      \t\t<DT><H3 ADD_DATE="5" LAST_MODIFIED="6">A</H3>
      \t\t<DL><p>
      \t\t\t<DT><A HREF="https://aa" ADD_DATE="7" LAST_MODIFIED="8">AA</A>
      \t\t</DL><p>
      \t</DL><p>
      </DL><p>
    HTML
    assert_equal exp, NbfTools::HTML.new(data).to_s
  end

  def test_merge_files_to_one_html
    file_content1 = <<~HTML.chomp
      <!DOCTYPE NETSCAPE-Bookmark-file-1>
      <!-- This is an automatically generated file.
           It will be read and overwritten.
           DO NOT EDIT! -->
      <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
      <TITLE>Bookmarks</TITLE>
      <H1>Bookmarks</H1>
      <DL><p>
      \t<DT><H3 ADD_DATE="1" LAST_MODIFIED="2" PERSONAL_TOOLBAR_FOLDER="true">书签工具栏</H3>
      \t<DL><p>
      \t\t<DT><A HREF="https://a" ADD_DATE="3" LAST_MODIFIED="4">A</A>
      \t\t<DT><H3 ADD_DATE="5" LAST_MODIFIED="6">A</H3>
      \t\t<DL><p>
      \t\t\t<DT><A HREF="https://aa" ADD_DATE="17" LAST_MODIFIED="18">AA</A>
      \t\t</DL><p>
      \t</DL><p>
      </DL><p>
    HTML
    IO.write("tmp/test_merge_files_to_one_html1.html", file_content1)
    file_content2 = <<~HTML.chomp
      <!DOCTYPE NETSCAPE-Bookmark-file-1>
      <!-- This is an automatically generated file.
           It will be read and overwritten.
           DO NOT EDIT! -->
      <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
      <TITLE>Bookmarks</TITLE>
      <H1>Bookmarks</H1>
      <DL><p>
      \t<DT><H3 ADD_DATE="1" LAST_MODIFIED="2" PERSONAL_TOOLBAR_FOLDER="true">栏签书</H3>
      \t<DL><p>
      \t\t<DT><A HREF="https://a" ADD_DATE="3" LAST_MODIFIED="4">A</A>
      \t\t<DT><H3 ADD_DATE="5" LAST_MODIFIED="6">A</H3>
      \t\t<DL><p>
      \t\t\t<DT><A HREF="https://ab" ADD_DATE="9" LAST_MODIFIED="10">AB</A>
      \t\t</DL><p>
      \t\t<DT><H3 ADD_DATE="11" LAST_MODIFIED="12">B</H3>
      \t\t<DL><p>
      \t\t\t<DT><A HREF="https://aa" ADD_DATE="13" LAST_MODIFIED="14">AA</A>
      \t\t\t<DT><A HREF="https://bb" ADD_DATE="15" LAST_MODIFIED="16">BB</A>
      \t\t</DL><p>
      \t</DL><p>
      </DL><p>
    HTML
    IO.write("tmp/test_merge_files_to_one_html2.html", file_content2)

    exp = <<~HTML.chomp
      <!DOCTYPE NETSCAPE-Bookmark-file-1>
      <!-- This is an automatically generated file.
           It will be read and overwritten.
           DO NOT EDIT! -->
      <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
      <TITLE>Bookmarks</TITLE>
      <H1>Bookmarks</H1>
      <DL><p>
      \t<DT><H3 ADD_DATE="1" LAST_MODIFIED="2" PERSONAL_TOOLBAR_FOLDER="true">书签工具栏</H3>
      \t<DL><p>
      \t\t<DT><A HREF="https://a" ADD_DATE="3" LAST_MODIFIED="4">A</A>
      \t\t<DT><H3 ADD_DATE="5" LAST_MODIFIED="6">A</H3>
      \t\t<DL><p>
      \t\t\t<DT><A HREF="https://aa" ADD_DATE="17" LAST_MODIFIED="18">AA</A>
      \t\t\t<DT><A HREF="https://ab" ADD_DATE="9" LAST_MODIFIED="10">AB</A>
      \t\t</DL><p>
      \t\t<DT><H3 ADD_DATE="11" LAST_MODIFIED="12">B</H3>
      \t\t<DL><p>
      \t\t\t<DT><A HREF="https://bb" ADD_DATE="15" LAST_MODIFIED="16">BB</A>
      \t\t</DL><p>
      \t</DL><p>
      </DL><p>
    HTML

    assert_equal exp, NbfTools.merge_files_to_one_html("tmp/test_merge_files_to_one_html1.html", "tmp/test_merge_files_to_one_html2.html")
  end
end
