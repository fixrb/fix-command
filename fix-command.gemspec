# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "fix-command"
  spec.version       = File.read("VERSION.semver").chomp
  spec.author        = "Cyril Kato"
  spec.email         = "contact@cyril.email"
  spec.summary       = "Fix extension gem for the fix command."
  spec.description   = "Provides the fix command to run specs."
  spec.homepage      = "https://github.com/fixrb/fix-command"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")
  spec.license       = "MIT"
  spec.files         = Dir["LICENSE.md", "README.md", "lib/**/*", "bin/fix"]
  spec.executables = ["fix"]

  spec.add_dependency "fix", "~> 0.18.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop-md"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rake"
  spec.add_development_dependency "rubocop-thread_safety"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "spectus"
  spec.add_development_dependency "yard"
end
