# Mtree

[![Build Status](https://travis-ci.com/opus-codium/mtree.svg?branch=master)](https://travis-ci.com/opus-codium/mtree)

This gem allows mtree styled hierarchy specifications — as found in the BSD world — to be parsed and updated from a Ruby program.  It also provide a `mtree` command with is backward compatible with [FreeBSD's `mtree(1)`](https://www.freebsd.org/cgi/man.cgi?query=mtree).

Not all the flags of FreeBSD `mtree(1)` are currently supported, the effor being driven by opus-labs' requirements.  Pull requests are accepted though, and we will be happy to merge your contribution!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mtree'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mtree

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/opus-codium/mtree. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mtree project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/smortex/mtree/blob/master/CODE_OF_CONDUCT.md).
