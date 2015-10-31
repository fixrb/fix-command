require_relative File.join '..', 'support', 'coverage'
require_relative File.join '..', '..', 'lib', 'fix', 'command'

require 'pathname'
bin_path = Pathname.new(__FILE__).join '..', '..', '..', 'bin', 'fix'

require 'spectus'
include Spectus

it { `#{bin_path} --help` }.MUST eql <<-OUTPUT
Usage: fix <files or directories> [options]

Specific options:
        --debug                      Enable ruby debug
        --warnings                   Enable ruby warnings

Common options:
        --help                       Show this message
        --version                    Show the version
OUTPUT
