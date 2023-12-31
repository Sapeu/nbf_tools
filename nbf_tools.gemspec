# frozen_string_literal: true

require_relative "lib/nbf_tools/version"

Gem::Specification.new do |spec|
  spec.name = "nbf_tools"
  spec.version = NbfTools::VERSION
  spec.authors = ["Sapeu"]
  spec.email = ["sapeu.lee@foxmail.com"]

  spec.summary = "NETSCAPE Bookmark file tools, parse and merge multiple files."
  spec.description = "NETSCAPE Bookmark file tools, parse file and merge multiple files.\nThe file was exported from Chrome, Edge, Firefox or Safari browser."
  spec.homepage = "https://github.com/sapeu/nbf_tools"
  spec.required_ruby_version = ">= 2.7.0"
  spec.license = "MIT"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sapeu/nbf_tools"
  spec.metadata["changelog_uri"] = "https://github.com/sapeu/nbf_tools/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "nokogiri", "~> 1.15"
  spec.add_development_dependency "standard", "~> 1.31"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
