require 'fix'
require 'optparse'
require 'set'

# Namespace for the Fix framework.
#
# @api public
#
# @example Let's test a duck's spec!
#   Fix::Command.run('duck_fix.rb', '-w')
#
module Fix
  # Open the command class.
  #
  # @api public
  #
  # @example Let's test a duck's spec!
  #   Command.run('duck_fix.rb', '-w')
  #
  class Command
    # Handle the parameters passed to fix command from the console.
    #
    # @api public
    #
    # @example Let's test a duck's spec!
    #   run('duck_fix.rb', '-w')
    #
    # @param args [Array] A list of files and options.
    #
    # @raise [SystemExit] The result of the tests.
    def self.run(*args)
      config = process_args(args)

      file_paths = fetch_file_paths(
        config.fetch(:prefix),
        config.fetch(:suffix), *args
      )

      str  = "\e[37m"
      str += '> fix'
      str += ' --debug'          if $DEBUG
      str += ' --warnings'       if $VERBOSE
      str += ' --prefix'         if config.fetch(:prefix)
      str += ' --suffix'         if config.fetch(:suffix)

      puts str + ' ' + file_paths.to_a.join(' ') + "\e[22m"

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

      opt_parser.parse!(args)
      options
    end

    # @private
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
