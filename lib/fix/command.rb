# frozen_string_literal: true

require "rbconfig"
require "shellwords"

# The namespace of Fix, which the command shares with the fix gem.
module Fix
  # The fix command: runs each specification file in a process of its own,
  # lets its results through, and tells how many files were met.
  #
  # A file is met when its process exits with 0, which is what
  # `exit(Fix[:Name].test { … })` gives at the end of a file. The status is
  # the one thing a subject cannot forge, so the command reads nothing else.
  #
  # @example
  #   Fix::Command.run(["fix/"]) # => 0
  module Command
    # The version of the command, written by --version.
    VERSION = File.read(File.join(__dir__, "..", "..", "VERSION.semver")).chomp
    DIRECTORY = "fix"
    PATTERN = "*_fix.rb"
    SEARCH = File.join("**", PATTERN)
    OPTION = /\A--(?:random(?:=\d+)?|help|version)\z/
    # The text of --help, and of a usage error.
    USAGE = <<~TEXT.freeze
      Usage: fix [OPTION]... [FILE|DIRECTORY]...

      Runs each file in a process of its own, with the Ruby that runs fix, and
      writes how many files were met. A directory stands for the #{PATTERN} files
      it holds, and no argument for the #{DIRECTORY} directory. The files run in the
      order of the arguments, those of a directory in the order of their names,
      or in a random order with --random, which writes first the command that
      runs them in the same order again.

      Options:
        --random         Run the files in a random order
        --random=SEED    Run the files in the random order of this seed
        --help           Show this message
        --version        Show the version

      Status: 0 when every file was met, 1 otherwise, 2 for a usage error.
    TEXT

    private_constant :DIRECTORY, :PATTERN, :SEARCH, :OPTION

    # Runs the command and returns its status.
    #
    # @param argv [Array<String>] the arguments: options and paths, in any order
    # @param out [IO] where the command and the files write
    # @param err [IO] where the usage errors go, and what the files write on their standard error
    # @return [Integer] 0 when every file was met, 1 otherwise, 2 for a usage error
    def self.run(argv, out: $stdout, err: $stderr)
      options, arguments = argv.partition { |argument| argument.start_with?("-") }
      unknown = options.find { |option| !option.match?(OPTION) }
      return usage(err, "unknown option: #{unknown}") if unknown
      return write(out, USAGE) if options.include?("--help")
      return write(out, VERSION) if options.include?("--version")

      test(arguments, options.find { |option| option.start_with?("--random") }, out, err)
    end

    # Writes the usage error on `err` and returns the status of a usage error.
    def self.usage(err, message)
      err.puts("fix: #{message}", USAGE)
      2
    end

    # Writes the text on `out` and returns the status of a run that had
    # nothing to test.
    def self.write(out, text)
      out.puts(text)
      0
    end

    # Runs the files of the arguments, in their order or in the random order
    # of the option, and returns the status.
    def self.test(arguments, random, out, err)
      paths = arguments.empty? ? [DIRECTORY] : arguments
      missing = paths.find { |path| !File.exist?(path) }
      return usage(err, "no such file or directory: #{missing}") if missing

      files = files(paths)
      return usage(err, "no file to run") if files.empty?

      files = shuffle(files, random, arguments, out) if random
      report(files, files.reject { |file| met?(file, out, err) }, out)
    end

    # The files of the arguments, in their order: a directory stands for the
    # files of the pattern it holds, at any depth, in the order of their names. The
    # directory is the base of the search, not part of the pattern, so that
    # its name is read as it is, however it is spelled; the pattern takes
    # the encoding of the argument, so that the paths found share it.
    def self.files(arguments)
      arguments.flat_map do |argument|
        next [argument] unless File.directory?(argument)

        Dir.glob(SEARCH.encode(argument.encoding), base: argument).map { |path| File.join(argument, path) }
      end
    end

    # The files in the random order of the seed of the option, drawn when the
    # option gives none, after writing the command that gives this order again.
    def self.shuffle(files, option, arguments, out)
      digits = option[/\A--random=(\d+)\z/, 1]
      seed = digits ? Integer(digits, 10) : Random.rand(2**32)
      out.puts(["fix", "--random=#{seed}", *arguments.map { |argument| Shellwords.escape(argument) }].join(" "))
      files.shuffle(random: Random.new(seed))
    end

    # Runs the file in a process of its own, writing where the command
    # writes, and tells whether it exited with 0. What the command wrote
    # before is flushed first, so that it comes before what the file writes.
    def self.met?(file, out, err)
      out.flush
      pid = Process.spawn(RbConfig.ruby, "--", file, out:, err:)
      Process.wait2(pid).last.success?
    end

    # Writes how many files were met, and returns 0 when all were, 1
    # otherwise.
    def self.report(files, unmet, out)
      count = "#{files.size} file#{"s" unless files.size == 1}"
      out.puts(unmet.empty? ? "#{count} met" : "#{count}, #{unmet.size} not met: #{unmet.join(", ")}")
      unmet.empty? ? 0 : 1
    end

    private_class_method :usage, :write, :test, :files, :shuffle, :met?, :report
  end
end
