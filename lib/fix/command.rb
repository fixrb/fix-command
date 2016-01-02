require 'fix'
require 'optparse'
require 'set'

# Namespace for the Fix framework.
#
# @api public
#
# @example Let's test a duck's spec!
#   Fix::Command.run('duck_fix.rb', '--warnings')
#
module Fix
  # Fix::Command reads command-line configuration options from files in two
  # different locations:
  #
  # * Local: "./.fix" (i.e. in the project's root directory)
  # * Global: "~/.fix" (i.e. in the user's home directory)
  #
  # Options declared in the local file override those in the global file, while
  # those declared in command-line will override any ".fix" file.
  COMMAND_LINE_OPTIONS_FILE = '.fix'

  # Open the command class.
  #
  # @api public
  #
  # @example Let's test a duck's spec!
  #   Command.run('duck_fix.rb', '--warnings')
  #
  class Command
    # Handle the parameters passed to fix command from the console.
    #
    # @api public
    #
    # @example Let's test a duck's spec!
    #   run('duck_fix.rb', '--warnings')
    #
    # @param args [Array] A list of files and options.
    #
    # @raise [SystemExit] The result of the tests.
    def self.run(*args)
      config = process_args(args)

      file_paths = fetch_file_paths(
        config.fetch(:prefix),
        config.fetch(:suffix), *args
      ).to_a.shuffle(random: Random.new(config.fetch(:random)))

      str  = "\e[37m"
      str += '> fix '
      str += file_paths.join(' ')
      str += ' --debug'          if $DEBUG
      str += ' --warnings'       if $VERBOSE
      str += ' --random'         if config.fetch(:random)
      str += ' --prefix'         if config.fetch(:prefix)
      str += ' --suffix'         if config.fetch(:suffix)

      puts "#{str} \e[22m"

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
    def self.process_args(args)
      options = {
        debug:          false,
        warnings:       false,
        random:         Random.new_seed,
        prefix:         '',
        suffix:         '_fix'
      }

      opt_parser = OptionParser.new do |opts|
        opts.banner = 'Usage: fix <files or directories> [options]'

        opts.separator ''
        opts.separator 'Specific options:'

        opts.on('--debug', 'Enable ruby debug') do
          options[:debug] = $DEBUG = true
        end

        opts.on('--warnings', 'Enable ruby warnings') do
          options[:warnings] = $VERBOSE = true
        end

        opts.on('--random=[SEED]', Integer, 'Predictable randomization') do |i|
          options[:random] = i
        end

        opts.on('--prefix=[PREFIX]', String, 'Prefix of the spec files') do |s|
          options[:prefix] = s
        end

        opts.on('--suffix=[SUFFIX]', String, 'Suffix of the spec files') do |s|
          options[:suffix] = s
        end

        opts.separator ''
        opts.separator 'Common options:'

        opts.on_tail '--help', 'Show this message' do
          puts opts
          exit
        end

        opts.on_tail '--version', 'Show the version' do
          puts File.read(File.join(File.expand_path(File.dirname(__FILE__)),
                                   '..',
                                   '..',
                                   'VERSION.semver')).chomp

          exit
        end
      end

      %w(~ .).each do |c|
        config_path = File.join(File.expand_path(c), COMMAND_LINE_OPTIONS_FILE)
        opt_parser.load(config_path)
      end

      opt_parser.parse!(args)

      options
    end

    # @private
    #
    # @return [Set] A list of absolute paths.
    def self.fetch_file_paths(file_prefix, file_suffix, *args)
      absolute_paths = Set.new

      args << '.' if args.empty?
      args.each do |s|
        s = File.absolute_path(s) unless s.start_with?(File::SEPARATOR)

        if File.directory?(s)
          spec_files = File.join(s, '**', "#{file_prefix}*#{file_suffix}.rb")
          Dir.glob(spec_files).each { |spec_f| absolute_paths.add(spec_f) }
        else
          absolute_paths.add(s)
        end
      end

      if absolute_paths.empty?
        warn 'Sorry, files or directories not found.'
        exit false
      end

      absolute_paths
    end
  end
end
