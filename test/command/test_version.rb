# frozen_string_literal: true

require_relative File.join '..', 'support', 'coverage'
require_relative File.join '..', '..', 'lib', 'fix', 'command'

require 'pathname'
bin_path = Pathname.new(__FILE__).join '..', '..', '..', 'bin', 'fix'

require 'spectus'
include Spectus

it { `#{bin_path} --version` }.MUST eql File.open(
  Pathname.new(__FILE__).join '..', '..', '..', 'VERSION.semver'
).read
