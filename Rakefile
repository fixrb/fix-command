# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"
require "yard"

Rake::TestTask.new do |t|
  t.pattern = "test/**/test_*.rb"
  t.verbose = true
  t.warning = true
end

RuboCop::RakeTask.new
YARD::Rake::YardocTask.new

task default: %i[yard rubocop:auto_correct test]
