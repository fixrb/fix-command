require_relative File.join 'support', 'coverage'
require_relative File.join '..', 'lib', 'fix', 'command'

require 'spectus'
include Spectus

it { Fix::Command.process_args([]) }.MUST eql(
  debug:    false,
  warnings: false,
  prefix:   '',
  suffix:   '_fix'
)

it { Fix::Command.process_args(['duck_fix.rb', '--warnings']) }.MUST eql(
  debug:    false,
  warnings: true,
  prefix:   '',
  suffix:   '_fix'
)

it { Fix::Command.process_args(['duck_fix.rb', '--prefix=fuu']) }.MUST eql(
  debug:    false,
  warnings: false,
  prefix:   'fuu',
  suffix:   '_fix'
)

it { Fix::Command.process_args(['duck_fix.rb', '--suffix=fuu']) }.MUST eql(
  debug:    false,
  warnings: false,
  prefix:   '',
  suffix:   'fuu'
)
