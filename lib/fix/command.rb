# frozen_string_literal: true

require 'fix'
require 'optparse'
require 'set'

# Namespace for the Fix framework.
#
# @api public
#
# @example Let's test a duck!
#   Fix::Command.run('./duck/', '--warnings')
#
module Fix
  # Open the command class.
  #
  # @api public
  #
  # @example Let's test a duck!
  #   Command.run('./duck/', '--warnings')
  #
  class Command
    # Handle the parameters passed to fix command from the console.
    #
    # @api public
    #
    # @example Let's test a duck's spec!
    #   run('./duck/', '--warnings')
    #
    # @param args [Array] A list of files and options.
    #
    # @raise [SystemExit] The result of the tests.
    def self.run(*args)
      config = process_args(true, args)

      if args.size > 1
        raise ArgumentError, "wrong number of directories (given #{args.size})"
      end

      file_paths = fetch_file_paths(
        config.fetch(:diff),
        config.fetch(:prefix),
        config.fetch(:suffix),
        (args.first || '.')
      ).to_a.sort.shuffle(random: Random.new(config.fetch(:random)))

      puts report(config, *file_paths)

      if file_paths.empty?
        puts 'Specs not found.'
        exit
      end

      status = true

      file_paths.each do |file_path|
        begin
          puts
          print "\e[30m#{file_path}\e[0m "
          require file_path
        rescue SystemExit => e
          status = false unless e.success?
        end
      end

      exit(status)
    end

    # @private
    #
    # @return [String] Report the command-line.
    def self.report(config, *file_paths)
      str = '> fix ' + file_paths.join(' ')
      str += ' --debug'     if $DEBUG
      str += ' --warnings'  if $VERBOSE
      str += ' --diff'      if config.fetch(:diff)
      str += " --random #{config.fetch(:random)}"
      str += " --prefix #{config.fetch(:prefix).inspect}"
      str += " --suffix #{config.fetch(:suffix).inspect}"

      ["\e[37m", str, "\e[0m"].join
    end

    # @private
    #
    # @param load_file  [Boolean] Preload configuration options from files.
    # @param args       [Array]   List of parameters.
    def self.process_args(load_file, args)
      options = {
        debug:    false,
        warnings: false,
        diff:     false,
        random:   Random.new_seed,
        prefix:   '',
        suffix:   '_fix'
      }

      # rubocop:disable BlockLength
      opt_parser = OptionParser.new do |opts|
        opts.banner = 'Usage: fix <directory> [options]'

        opts.separator ''
        opts.separator 'Specific options:'

        opts.on('--[no-]debug', 'Enable ruby debug') do |b|
          options[:debug] = $DEBUG = b
        end

        opts.on('--[no-]warnings', 'Enable ruby warnings') do |b|
          options[:warnings] = $VERBOSE = b
        end

        opts.on('--[no-]diff', 'Regression test selection') do |b|
          options[:diff] = b
        end

        opts.on('--random [SEED]', Integer, 'Predictable randomization') do |i|
          options[:random] = Integer(i)
        end

        opts.on('--prefix [PREFIX]', String, 'Prefix of the spec files') do |s|
          options[:prefix] = s.to_s
        end

        opts.on('--suffix [SUFFIX]', String, 'Suffix of the spec files') do |s|
          options[:suffix] = s.to_s
        end

        opts.separator ''
        opts.separator 'Common options:'

        opts.on_tail '-h', '--help', 'Show this message' do
          puts opts
          exit
        end

        opts.on_tail '-v', '--version', 'Show the version' do
          puts File.read(File.join(File.expand_path(File.dirname(__FILE__)),
                                   '..',
                                   '..',
                                   'VERSION.semver')).chomp

          exit
        end
      end
      # rubocop:enable BlockLength

      if load_file
        config_paths.each { |config_path| opt_parser.load(config_path) }
      end

      opt_parser.parse!(args)

      options
    end

    # @return [String] The configuration file.
    def self.config_file
      '.fix'
    end

    # @return [Array] Different locations of command-line configuration options.
    def self.config_paths
      %w[~ .].map { |char| File.join(File.expand_path(char), config_file) }
    end

    # @private
    #
    # @return [Set] A list of absolute paths.
    def self.fetch_file_paths(diff, prefix, suffix, path)
      unless File.directory?(path)
        warn 'Sorry, invalid directory.'
        exit false
      end

      path = File.absolute_path(path) unless path.start_with?(File::SEPARATOR)

      spec_paths = Dir.glob(File.join(path, '**', "#{prefix}*#{suffix}.rb")).to_set
      return spec_paths unless diff

      Dir.chdir(path) do
        modified_paths = git_diff_paths

        # select only modified specs
        modified_spec_paths = spec_paths & modified_paths

        # select only unmodified specs
        unmodified_spec_paths = spec_paths - modified_spec_paths

        # select only modified code
        modified_code_paths = modified_paths - spec_paths
        modified_code_filenames = modified_code_paths.map do |p|
          p.split(File::SEPARATOR).last.gsub(/\.rb\z/, '')
        end.to_set

        # select only specs of the modified code
        additional_spec_paths = unmodified_spec_paths.select do |unmodified_spec_path|
          unmodified_spec_filename = unmodified_spec_path.split(File::SEPARATOR).last.gsub(/\.rb\z/, '')
          modified_code_filenames.any? do |modified_code_filename|
            unmodified_spec_filename.include?(modified_code_filename)
          end
        end

        modified_spec_paths + additional_spec_paths
      end
    end

    # @return [Set] The list of modified files.
    def self.git_diff_paths
      `git status --porcelain`
        .split("\n")
        .map { |p| File.absolute_path(p.split.last) }
        .to_set
    end
  end
end
