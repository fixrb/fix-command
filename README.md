# fix-command

The `fix` command runs each specification file of [Fix](https://github.com/fixrb/fix) in a process of its own, lets their results through, and tells how many files were met: its status is 0 when every file is.

## Installation

Add `gem "fix-command"` to your Gemfile, or run `gem install fix-command`. It brings `fix` with it. Ruby 3.3 or later is required, with `fork(2)`, as Fix requires it.

## Usage

A specification file ends with `exit(Fix[:Name].test { … })`, which makes the status of its process 0 when the specification is met and 1 otherwise. The command runs such files, with the Ruby that runs it, and reads that status, the one thing a subject cannot forge: it reads nothing else, and what the files write goes through as it is.

```console
$ fix
fix/account_fix.rb:6: Success: expected 100 to eq 100
fix/account_fix.rb:7: Failure: expected 100 to eq 200
fix/duck_fix.rb:5: Success: expected "Quack!" to eq "Quack!"
fix/lot/empty_fix.rb:5: Success: expected 0 to eq 0
3 files, 1 not met: fix/account_fix.rb
$ echo $?
1
```

Without an argument, `fix` runs the `*_fix.rb` files of the `fix` directory, at any depth: `fix/` is to Fix what `test/` is to minitest. With arguments, it runs the files given, whatever their names (one that starts with a dash is given with its directory, `./-x_fix.rb`), and the `*_fix.rb` files of the directories given, in the order of their names. As the `*` of the shell, the search leaves out the names that start with a dot, and it does not follow a symbolic link to a directory:

```console
$ fix fix/duck_fix.rb lib/
```

The files run one after the other, each in a new process: an `exit`, a global, a constant, the current directory or `ENV` changed by one file do not reach the next. Each file is on its own for what it needs too, a `require_relative "../lib/account"` for its subject, say. What the processes inherit is the environment of the command: `bundle exec fix` gives every file the gems of the Gemfile, `RUBYOPT=-Ilib fix` adds `lib` to their load path, and `RUBYOPT=-w fix` runs them with warnings.

### Random order

A context runs in a child process, so the order of the contexts of a file cannot change a result, and neither can the order of the files, as far as the process goes. What a subject does outside the process can depend on it, though: a database or a file that one specification leaves changed for the next. `--random` runs the files in a random order, and writes first the command that runs them in the same order again:

```console
$ fix --random
fix --random=3
fix/duck_fix.rb:5: Success: expected "Quack!" to eq "Quack!"
fix/account_fix.rb:6: Success: expected 100 to eq 100
fix/account_fix.rb:7: Failure: expected 100 to eq 200
fix/lot/empty_fix.rb:5: Success: expected 0 to eq 0
3 files, 1 not met: fix/account_fix.rb
```

### Status

0 when every file was met, 1 when one was not: a specification not met, a file that raised when loaded, a process that died. 2 for a usage error, written on the standard error with the usage: an unknown option, a path that does not exist, or no file to run. `--help` writes the usage, `--version` the version.

## What the command does not do

- It does not read the results: no count of expectations, no colour, no letter per expectation. The lines are those of Fix, one per expectation, `LOCATION: OUTCOME: SUMMARY`, with the backtrace of an error below; `grep` counts them if needed.
- It has no timeout: a file that never ends holds the command, as it would hold `ruby`. Ctrl-C ends the command and, through the terminal, the file being run.
- It runs the files one at a time.
- It takes no option for `ruby`: `RUBYOPT` and `RUBYLIB` do that, and `bundle exec` the rest.

## Versioning

fix-command follows [Semantic Versioning 2.0](https://semver.org/).

## License

The [gem](https://rubygems.org/gems/fix-command) is available as open source under the terms of the [MIT License](https://github.com/fixrb/fix-command/raw/main/LICENSE.md).

## Sponsors

This project is sponsored by [Sashité](https://sashite.com/).
