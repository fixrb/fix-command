require_relative File.join '..', 'support', 'coverage'
require_relative File.join '..', '..', 'lib', 'fix', 'command'

[:pathname, :spectus].each { |lib| require lib.to_s }

bin_path = Pathname.new(__FILE__).join '..', '..', '..', 'bin', 'fix'

Spectus.this { `#{bin_path} --help` }.MUST Eql: <<-OUTPUT
Usage: fix <files or directories> [options]

Specific options:
        --debug                      Enable ruby debug
        --warnings                   Enable ruby warnings

Common options:
        --help                       Show this message
        --version                    Show the version
OUTPUT
