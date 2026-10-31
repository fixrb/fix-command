# frozen_string_literal: true

require_relative File.join("support", "coverage")
require_relative File.join("..", "lib", "fix", "command")
require "open3"
require "rbconfig"
require "shellwords"
require "tempfile"
require "tmpdir"

# The paths are relative to the repository, as a developer writes them.
Dir.chdir(File.expand_path("..", __dir__))

EXPECTED_VERSION = File.read("VERSION.semver").chomp
MET = "test/fixtures/met"
UNMET = "test/fixtures/unmet"
STREAMS = "test/fixtures/streams"
UNMET_FILES = "#{UNMET}/c_fix.rb, #{UNMET}/d_fix.rb, #{UNMET}/e_fix.rb".freeze

# Runs the command with the arguments, and gives its status and what it wrote
# on the standard output and error, the files included.
def fix(*argv)
  Tempfile.create("out") do |out|
    Tempfile.create("err") do |err|
      status = Fix::Command.run(argv, out: out, err: err)
      [out, err].each(&:flush)
      [status, File.read(out.path), File.read(err.path)]
    end
  end
end

# --help and --version write on the standard output, and the status is 0.
status, out, err = fix("--help")
raise unless status.zero? && out == Fix::Command::USAGE && err.empty?
raise unless Fix::Command::USAGE.start_with?("Usage: fix [OPTION]... [FILE|DIRECTORY]...\n")
status, out, err = fix("--version")
raise unless status.zero? && out == "#{EXPECTED_VERSION}\n" && err.empty?
raise unless Fix::Command::VERSION == EXPECTED_VERSION
# An option wins over the paths, wherever it is.
raise unless fix(MET, "--help") == [0, Fix::Command::USAGE, ""]
raise unless fix("--version", MET) == [0, "#{EXPECTED_VERSION}\n", ""]

# An unknown option is a usage error, on the standard error, with the usage;
# nothing runs.
status, out, err = fix("--bogus", MET)
raise unless status == 2 && out.empty? && err == "fix: unknown option: --bogus\n#{Fix::Command::USAGE}"
raise unless fix("-h", MET) == [2, "", "fix: unknown option: -h\n#{Fix::Command::USAGE}"]
raise unless fix("---help", MET) == [2, "", "fix: unknown option: ---help\n#{Fix::Command::USAGE}"]
raise unless fix("--random=seven", MET) == [2, "", "fix: unknown option: --random=seven\n#{Fix::Command::USAGE}"]
raise unless fix("--random=", MET) == [2, "", "fix: unknown option: --random=\n#{Fix::Command::USAGE}"]
raise unless fix("--", MET) == [2, "", "fix: unknown option: --\n#{Fix::Command::USAGE}"]
# An unknown option is an error before --help is read; --help wins over
# --version and --random.
raise unless fix("--help", "--bogus").first == 2
raise unless fix("--version", "--help") == fix("--help")
raise unless fix("--random", "--help") == fix("--help")

# A path that does not exist is a usage error; nothing runs.
status, out, err = fix(MET, "nope.rb")
raise unless status == 2 && out.empty? && err.start_with?("fix: no such file or directory: nope.rb\n")

# No argument stands for the fix directory: its *_fix.rb files, at any
# depth, leaving out the names that start with a dot, as the shell does.
Dir.mktmpdir do |project|
  Dir.mkdir(File.join(project, "fix"))
  Dir.mkdir(File.join(project, "fix", ".hidden"))
  File.write(File.join(project, "fix", "x_fix.rb"), "")
  File.write(File.join(project, "fix", "fix.rb"), "exit 1")
  File.write(File.join(project, "fix", ".y_fix.rb"), "exit 1")
  File.write(File.join(project, "fix", ".hidden", "z_fix.rb"), "exit 1")
  raise unless Dir.chdir(project) { fix } == [0, "1 file met\n", ""]
  raise unless Dir.chdir(project) { fix("--random=1") } == [0, "fix --random=1\n1 file met\n", ""]
end
# A usage error where there is no fix directory.
Dir.mktmpdir do |nowhere|
  status, out, err = Dir.chdir(nowhere) { fix }
  raise unless status == 2 && out.empty? && err.start_with?("fix: no such file or directory: fix\n")
end

# A directory without a file of the pattern is a usage error.
Dir.mktmpdir do |empty|
  status, out, err = fix(empty)
  raise unless status == 2 && out.empty? && err.start_with?("fix: no file to run\n")
end

# The name of a directory is read as it is, whatever characters it holds,
# and the command written by --random quotes a path for the shell.
Dir.mktmpdir do |tmp|
  odd = File.join(tmp, "[a] b{c}")
  Dir.mkdir(odd)
  File.write(File.join(odd, "g_fix.rb"), "")
  status, out, = fix(odd)
  raise unless status.zero? && out == "1 file met\n"
  status, out, = fix("--random=1", odd)
  raise unless status.zero? && out == "fix --random=1 #{Shellwords.escape(odd)}\n1 file met\n"
end

# Under a locale that is not UTF-8, the arguments are binary strings: the
# paths found in a directory take their encoding, and join with them.
Dir.mktmpdir do |tmp|
  accented = File.join(tmp, "é dir")
  Dir.mkdir(accented)
  File.write(File.join(accented, "ü_fix.rb"), "exit 1")
  File.write(File.join(tmp, "ö_fix.rb"), "exit 1")
  status, out, = fix(accented.b, File.join(tmp, "ö_fix.rb").b)
  raise unless status == 1 && out.b == "2 files, 2 not met: #{accented}/ü_fix.rb, #{tmp}/ö_fix.rb\n".b
end

# A directory stands for its *_fix.rb files, at any depth, in the order of
# their names; a file of another name is not run. The files write where the
# command writes, before the count.
status, out, err = fix(MET)
raise unless status.zero?
raise unless out == "#{MET}/a_fix.rb:7: Success: expected 1 to eq 1\nb\n2 files met\n"
raise unless err.empty?

# A file that fails, raises or dies is not met: the status is 1, and the
# count names the files, in the order they ran.
status, out, err = fix(UNMET)
raise unless status == 1
raise unless out == "#{UNMET}/c_fix.rb:7: Failure: expected 1 to eq 2\n3 files, 3 not met: #{UNMET_FILES}\n"
raise unless err.include?("boom (RuntimeError)")

# Files and directories mix, in the order of the arguments, a directory
# given with a trailing slash too; a file is run whatever its name; one file
# is one file.
raise unless fix("#{MET}/a_fix.rb", "#{UNMET}/d_fix.rb").first == 1
status, out, = fix("#{UNMET}/d_fix.rb", "#{UNMET}/c_fix.rb")
raise unless status == 1 && out.lines.last == "2 files, 2 not met: #{UNMET}/d_fix.rb, #{UNMET}/c_fix.rb\n"
raise unless fix("#{UNMET}/") == fix(UNMET)
status, out, = fix("#{MET}/a_fix.rb", UNMET)
raise unless status == 1 && out.end_with?("4 files, 3 not met: #{UNMET_FILES}\n")
status, out, = fix("#{MET}/other.rb")
raise unless status == 1 && out == "1 file, 1 not met: #{MET}/other.rb\n"
status, out, = fix("#{MET}/deep/b_fix.rb")
raise unless status.zero? && out == "b\n1 file met\n"

# The standard output and error of a file go where those of the command go.
status, out, err = fix(STREAMS)
raise unless status.zero? && out == "on the standard output\n1 file met\n" && err == "on the standard error\n"

# --random=SEED runs the files in the order the seed gives, after writing the
# command that gives it again; the count follows that order.
files = Dir.glob("#{UNMET}/*_fix.rb")
expected = files.shuffle(random: Random.new(7))
raise "a seed that keeps the order" if expected == files
status, out, = fix("--random=7", UNMET)
raise unless status == 1
raise unless out.lines.first == "fix --random=7 #{UNMET}\n"
raise unless out.lines.last == "3 files, 3 not met: #{expected.join(", ")}\n"
raise unless fix("--random=7", UNMET) == fix(UNMET, "--random=7")

# --random draws a seed, and the command written gives the same order again.
status, out, err = fix("--random", MET, UNMET)
raise unless status == 1
seed = out.lines.first.delete_prefix("fix --random=").delete_suffix(" #{MET} #{UNMET}\n")
raise "no seed written" unless seed.match?(/\A\d+\z/)
raise unless fix("--random=#{seed}", MET, UNMET) == [status, out, err]
raise unless fix("--random=#{2**64}", MET).first.zero?
# A seed is read in base ten, whatever its leading zeros.
raise unless fix("--random=08", UNMET) == fix("--random=8", UNMET)

# The command is run with the Ruby that runs fix: the file sees the same one.
Tempfile.create(%w[ruby _fix.rb]) do |file|
  file.write("puts RbConfig.ruby")
  file.close
  _, out, = fix(file.path)
  raise unless out == "#{RbConfig.ruby}\n1 file met\n"
end

# The executable exits with the status.
exe = File.join("exe", "fix")
out, err, status = Open3.capture3(RbConfig.ruby, exe, "--version")
raise unless status.exitstatus.zero? && out == "#{EXPECTED_VERSION}\n" && err.empty?
out, err, status = Open3.capture3(RbConfig.ruby, exe, "#{MET}/deep/b_fix.rb", UNMET)
raise unless status.exitstatus == 1 && out.start_with?("b\n") && out.end_with?("3 not met: #{UNMET_FILES}\n")
raise unless err.include?("boom")
raise unless Open3.capture3(RbConfig.ruby, exe, "--bogus").last.exitstatus == 2

# Ctrl-C, an interrupt of the whole process group, ends the command with
# the status of an interrupted process, without a backtrace of its own: what
# the file writes when interrupted is the file's.
Dir.mktmpdir do |tmp|
  File.write(File.join(tmp, "sleep_fix.rb"), "puts :sleeping\n$stdout.flush\nsleep 60\n")
  out = File.join(tmp, "out")
  err = File.join(tmp, "err")
  pid = Process.spawn(RbConfig.ruby, exe, tmp, pgroup: true, out: out, err: err)
  100.times do
    break if File.exist?(out) && File.read(out) == "sleeping\n"

    sleep 0.05
  end
  Process.kill(:INT, -pid)
  status = Process.wait2(pid).last
  raise "status #{status}" unless status.exitstatus == 130
  written = File.read(err)
  raise "the command wrote a backtrace: #{written}" if written.include?("command.rb") || written.include?(exe)
end

# The surface is run alone, with its usage and its version.
raise unless Fix::Command.singleton_methods.sort == %i[run]
raise unless Fix::Command.constants.sort == %i[USAGE VERSION]
