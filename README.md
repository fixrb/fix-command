# Fix::Command

[![Build Status](https://travis-ci.org/fixrb/fix-command.svg?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/fixrb/fix-command/badges/gpa.svg)][codeclimate]
[![Gem Version](https://badge.fury.io/rb/fix-command.svg)][gem]
[![Inline docs](http://inch-ci.org/github/fixrb/fix-command.svg?branch=master)][inchpages]
[![Documentation](http://img.shields.io/:yard-docs-38c800.svg)][rubydoc]

> Provides the `fix` command with several options.

## Contact

* Home page: https://github.com/fixrb/fix-command
* Bugs/issues: https://github.com/fixrb/fix-command/issues
* Support: https://stackoverflow.com/questions/tagged/fixrb

## Rubies

* [MRI](https://www.ruby-lang.org/)
* [Rubinius](http://rubini.us/)
* [JRuby](http://jruby.org/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fix-command'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fix-command

## Usage

First, let's see the API:

    $ fix --help
    Usage: fix <directory> [options]

    Specific options:
            --[no-]debug                 Enable ruby debug
            --[no-]warnings              Enable ruby warnings
            --[no-]diff                  Regression test selection
            --random [SEED]              Predictable randomization
            --prefix [PREFIX]            Prefix of the spec files
            --suffix [SUFFIX]            Suffix of the spec files

    Common options:
        -h, --help                       Show this message
        -v, --version                    Show the version

And second, let's run a test:

    $ fix ./app/ --prefix test_ --suffix --diff
    > fix /Users/bob/app/duck_fix.rb --diff --random 198142038504094374390860708229193114294 --prefix "test_" --suffix ""

    /Users/bob/app/duck_fix.rb ..

    Ran 2 tests in 0.000382 seconds
    100% compliant - 0 infos, 0 failures, 0 errors

### Store Command Line Options

You can store command-line configuration options in a `.fix` file in two different locations:

* Local: "`./.fix`" (i.e. in the project's root directory)
* Global: "`~/.fix`" (i.e. in the user's home directory)

__Fix::Command__ will thus read them as though you typed them on the command-line.

Options declared in the local file override those in the global file, while those declared in command-line will override any ".fix" file.

## Security

As a basic form of security __Fix::Command__ provides a set of SHA512 checksums for every Gem release.  These checksums can be found in the `checksum/` directory.  Although these checksums do not prevent malicious users from tampering with a built Gem they can be used for basic integrity verification purposes.

The checksum of a file can be checked using the `sha512sum` command.  For example:

    $ sha512sum pkg/fix-command-0.1.0.gem
    26198b7812a5ac118a5f2a1b63927871b3378efb071b37abb7e1ba87c1aac9f3a6b45eeae87d9dc647b194c15171b13f15e46503a9a1440b1233faf924381ff5  pkg/fix-command-0.1.0.gem

## Versioning

__Fix::Command__ follows [Semantic Versioning 2.0](http://semver.org/).

## Contributing

1. [Fork it](https://github.com/fixrb/fix-command/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

See `LICENSE.md` file.

[gem]: https://rubygems.org/gems/fix-command
[travis]: https://travis-ci.org/fixrb/fix-command
[codeclimate]: https://codeclimate.com/github/fixrb/fix-command
[gemnasium]: https://gemnasium.com/fixrb/fix-command
[inchpages]: http://inch-ci.org/github/fixrb/fix-command
[rubydoc]: http://rubydoc.info/gems/fix-command/frames

***

This project is sponsored by:

[![Sashite](https://sashite.com/img/sashite.png)](https://sashite.com/)
