# Fix::Command

[![Build Status](https://travis-ci.org/fixrb/fix-command.svg?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/fixrb/fix-command/badges/gpa.svg)][codeclimate]
[![Dependency Status](https://gemnasium.com/fixrb/fix-command.svg)][gemnasium]
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

__Fix::Command__ is cryptographically signed.

To be sure the gem you install hasn't been tampered with, add my public key (if you haven't already) as a trusted certificate:

    $ gem cert --add <(curl -Ls https://raw.github.com/fixrb/fix-command/master/certs/gem-fixrb-public_cert.pem)
    $ gem install fix-command -P HighSecurity

The `HighSecurity` trust profile will verify all gems.  All of __Fix::Command__'s dependencies are signed.

Or add this line to your application's Gemfile:

```ruby
gem 'fix-command'
```

And then execute:

    $ bundle

## Usage

First, let's see the API:

    $ bundle exec fix --help
    Usage: fix <files or directories> [options]

    Specific options:
            --debug                      Enable ruby debug
            --warnings                   Enable ruby warnings
            --random=[SEED]              Predictable randomization
            --prefix=[PREFIX]            Prefix of the spec files
            --suffix=[SUFFIX]            Suffix of the spec files

    Common options:
            --help                       Show this message
            --version                    Show the version

And second, let's run a test:

    $ bundle exec fix duck_fix.rb --warnings
    > fix /Users/bob/code/duck_fix.rb --warnings

    /Users/bob/code/duck_fix.rb ..I

    1. Info: undefined method `sings' for #<Duck:0x007fdbeb05c1d8> (NoMethodError).

    Ran 3 tests in 0.000612 seconds
    100% compliant - 1 infos, 0 failures, 0 errors

### Store Command Line Options

You can store command line options in a `.fix` file in the project's root directory, and the fix command will read them as though you typed them on the command line.

## Security

As a basic form of security __Fix::Command__ provides a set of SHA512 checksums for
every Gem release.  These checksums can be found in the `checksum/` directory.
Although these checksums do not prevent malicious users from tampering with a
built Gem they can be used for basic integrity verification purposes.

The checksum of a file can be checked using the `sha512sum` command.  For
example:

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

[![Sashite](http://www.sashite.com/assets/img/sashite.png)](http://www.sashite.com/)
