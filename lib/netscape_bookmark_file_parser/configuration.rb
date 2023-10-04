module NetscapeBookmarkFileParser
  class Configuration
    # personal toolbar folder text, default: ''
    attr_accessor :personal_toolbar_folder_text
    # link type text, default: 'link'
    attr_accessor :link_type_text
    # folder type text, default: 'folder'
    attr_accessor :folder_type_text
    attr_accessor :nbf_template_path

    attr_accessor :body_template
    attr_accessor :link_template
    attr_accessor :folder_template
  end
end
