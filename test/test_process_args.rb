require_relative File.join 'support', 'coverage'
require_relative File.join '..', 'lib', 'fix', 'command'

require 'spectus'
include Spectus

it { Fix::Command.process_args([]).keys.to_set }.MUST eql(
  Set[:debug, :warnings, :random, :prefix, :suffix]
)

it do
  Fix::Command.process_args([
    'duck_fix.rb',
    '--random=0',
    '--warnings'
  ])
end.MUST eql(
  debug:    false,
  warnings: true,
  random:   0,
  prefix:   '',
  suffix:   '_fix'
)

it do
  Fix::Command.process_args([
    'duck_fix.rb',
    '--random=0',
    '--prefix=fuu'
  ])
end.MUST eql(
  debug:    false,
  warnings: false,
  random:   0,
  prefix:   'fuu',
  suffix:   '_fix'
)

it do
  Fix::Command.process_args([
    'duck_fix.rb',
    '--random=0',
    '--suffix=fuu'
  ])
end.MUST eql(
  debug:    false,
  warnings: false,
  random:   0,
  prefix:   '',
  suffix:   'fuu'
)

it do
  Fix::Command.process_args([
    'duck_fix.rb',
    '--random=42'
  ])
end.MUST eql(
  debug:    false,
  warnings: false,
  random:   42,
  prefix:   '',
  suffix:   '_fix'
)
