require_relative File.join '..', 'support', 'coverage'
require_relative File.join '..', '..', 'lib', 'fix', 'command'

require 'pathname'
bin_path = Pathname.new(__FILE__).join '..', '..', '..', 'bin', 'fix'

require 'spectus'
include Spectus

it { `#{bin_path} --help` }.MUST eql <<-OUTPUT
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
OUTPUT
