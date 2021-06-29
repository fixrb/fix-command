# Fix::Command

[![Version](https://img.shields.io/github/v/tag/fixrb/fix-command?label=Version&logo=github)](https://github.com/fixrb/fix-command/releases)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/fixrb/fix-command/main)
[![CI](https://github.com/fixrb/fix-command/workflows/CI/badge.svg?branch=main)](https://github.com/fixrb/fix-command/actions?query=workflow%3Aci+branch%3Amain)
[![RuboCop](https://github.com/fixrb/fix-command/workflows/RuboCop/badge.svg?branch=main)](https://github.com/fixrb/fix-command/actions?query=workflow%3Arubocop+branch%3Amain)
[![License](https://img.shields.io/github/license/fixrb/fix-command?label=License&logo=github)](https://github.com/fixrb/fix-command/raw/main/LICENSE.md)

> Provides the `fix` command with several options.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "fix-command"
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
## Contact

* Home page: https://github.com/fixrb/fix-command
* Bugs/issues: https://github.com/fixrb/fix-command/issues

## Versioning

__Fix::Command__ follows [Semantic Versioning 2.0](https://semver.org/).

## License

The [gem](https://rubygems.org/gems/fix-command) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

***

<p>
  This project is sponsored by:<br />
  <a href="https://sashite.com/"><img
    src="https://github.com/fixrb/fix-command/raw/main/img/sashite.png"
    alt="Sashite" /></a>
</p>
