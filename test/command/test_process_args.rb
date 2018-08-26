# frozen_string_literal: true

require_relative File.join '..', 'support', 'coverage'
require_relative File.join '..', '..', 'lib', 'fix', 'command'

require 'spectus'
include Spectus

it { Fix::Command.process_args(false, []).keys.to_set }.MUST eql(
  Set[:debug, :warnings, :diff, :random, :prefix, :suffix]
)

it { Fix::Command.process_args(false, []).fetch(:debug) }.MUST be_false
it { Fix::Command.process_args(false, ['--debug']).fetch(:debug) }.MUST be_true
it { Fix::Command.process_args(false, ['--no-debug']).fetch(:debug) }.MUST be_false

it { Fix::Command.process_args(false, []).fetch(:warnings) }.MUST be_false
it { Fix::Command.process_args(false, ['--warnings']).fetch(:warnings) }.MUST be_true
it { Fix::Command.process_args(false, ['--no-warnings']).fetch(:warnings) }.MUST be_false

it { Fix::Command.process_args(false, []).fetch(:diff) }.MUST be_false
it { Fix::Command.process_args(false, ['--diff']).fetch(:diff) }.MUST be_true
it { Fix::Command.process_args(false, ['--no-diff']).fetch(:diff) }.MUST be_false

it { Fix::Command.process_args(false, ['--random', '42']).fetch(:random) }.MUST equal(42)

it { Fix::Command.process_args(false, []).fetch(:prefix) }.MUST eql('')
it { Fix::Command.process_args(false, ['--prefix']).fetch(:prefix) }.MUST eql('')
it { Fix::Command.process_args(false, ['--prefix', 'fuu']).fetch(:prefix) }.MUST eql('fuu')

it { Fix::Command.process_args(false, []).fetch(:suffix) }.MUST eql('_fix')
it { Fix::Command.process_args(false, ['--suffix']).fetch(:suffix) }.MUST eql('')
it { Fix::Command.process_args(false, ['--suffix', 'fuu']).fetch(:suffix) }.MUST eql('fuu')
