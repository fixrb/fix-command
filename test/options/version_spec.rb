require_relative File.join '..', 'support', 'coverage'
require_relative File.join '..', '..', 'lib', 'fix', 'command'

[:pathname, :spectus].each { |lib| require lib.to_s }

bin_path = Pathname.new(__FILE__).join '..', '..', '..', 'bin', 'fix'

Spectus.this { `#{bin_path} --version` }.MUST Eql: File.open(
  Pathname.new(__FILE__).join '..', '..', '..', 'VERSION.semver'
).read
