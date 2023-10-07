# NbfTools

NETSCAPE Bookmark file tools，file from chrome edge firefox safari browser

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add nbf_tools

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install nbf_tools

## Usage

Parse NETSCAPE Bookmark file.

```ruby
NbfTools.parse bookmark_file_path
```

Merge and parse NETSCAPE Bookmark files.

```ruby
NbfTools.parse_files_in_one bookmark_file_path1, bookmark_file_path2
```

Export merge NETSCAPE Bookmark files to one html string.

```ruby
NbfTools.parse_files_in_one_html bookmark_file_path1, bookmark_file_path2
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Sapeu/nbf_tools.
