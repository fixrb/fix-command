# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "fix-command"
  spec.version                = File.read(File.join(__dir__, "VERSION.semver")).chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "The fix command: runs specification files of Fix, each in a process of its own"
  spec.description            = "The fix command runs each specification file of Fix in a process of its own, " \
                                "lets their results through, and tells how many files were met: " \
                                "its status is 0 when every file is."
  spec.homepage               = "https://fixrb.dev/gems/fix-command/"
  spec.license                = "MIT"
  spec.files                  = Dir["LICENSE.md", "README.md", "VERSION.semver", "exe/*", "lib/**/*.rb", base: __dir__]
  spec.bindir                 = "exe"
  spec.executables            = ["fix"]
  spec.required_ruby_version  = ">= 3.3.0"

  spec.metadata["bug_tracker_uri"]       = "https://github.com/fixrb/fix-command/issues"
  spec.metadata["documentation_uri"]     = "https://rubydoc.info/gems/fix-command"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"]       = "https://github.com/fixrb/fix-command"

  spec.add_dependency "fix", "~> 1.0"
end
