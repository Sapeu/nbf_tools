# NbfTools

NETSCAPE Bookmark file tools, parse and merge multiple files.

The file was exported from Chrome, Edge, Firefox or Safari browser.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add nbf_tools

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install nbf_tools

## Usage

### Command

Help.

```sh
usage: nbf_tools [options]
          -f, --files                         NETSCAPE Bookmark files, delimit by space
          -o, --out-format                    output parse result format (default: html), options: json, html
          -t, --personal-toolbar-folder-text  custom personal toolbar folder text

      other options:
          -h, --help                      print help
          -v, --version                   print version
```

Example.

```sh
# print merged json
nbf_tools -f bk2.html bk1.html -o json

# save merged new html file
nbf_tools -f bk2.html bk1.html -o json > bk.html
```

### Code

Example.

```ruby
require "nbf_tools"

# parse file
# options: `{personal_toolbar_folder_text: "some string"}`, is optional
NbfTools.parse "bk2.html"

# merge and parse multiple files
# options: `{personal_toolbar_folder_text: "some string"}`, is optional
NbfTools.parse_files_to_one "bk1.html", "bk2.html", personal_toolbar_folder_text: "bk"

# merge multiple files into one html string
# options: `{personal_toolbar_folder_text: "some string"}`, is optional
NbfTools.merge_files_to_one_html "bk1.html", "bk2.html"

# parse and merge operate with options
# options: `{files: [], personal_toolbar_folder_text: [], out_format: []}`
# `:files` must present
# `:personal_toolbar_folder_text` is optional
# if `:out_format` is `"json"` return json format else retrun return html format
NbfTools.merge_files_to_one_html(files: %w[bk1.html bk2.html], personal_toolbar_folder_text: [], out_format: %w[json])
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake test` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Sapeu/nbf_tools.
