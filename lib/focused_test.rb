#!/usr/local/bin/ruby
require 'optparse'

class FocusedTest
  class << self
    def run(*args)
      new(*args).run
    end
  end

  def initialize(*args)
    parse args
  end

  def run
    test_type = nil
    current_method = nil

    content = IO.read(@file_path)
    if content =~ /class .*Test < (.*TestCase|ActionController::IntegrationTest)/
      run_test content
    else
      run_example
    end
  end

  protected
  def parse(args)
    @file_path = nil
    @line_number = nil
    @rspec_version = ""
    @show_backtrace = false
    options = OptionParser.new do |o|
      o.on('-f', '--filepath=FILEPATH', String, "File to run test on") do |path|
        @file_path = path
      end

      o.on('-l', '--linenumber=LINENUMBER', Integer, "Line of the test") do |line|
        @line_number = line
      end
      o.on('-r', '--rspec-version=VERSION', String, "Version of Rspec to Run") do |version|
        @rspec_version = "_#{version}_"
      end

      o.on('-b', '--backtrace', String, "Show the backtrace of errors") do
        @show_backtrace = true
      end

      o.on('-X', '--drb', String, "Run examples via DRb.") do
        @drb = true
      end
    end
    options.order(args)
  end

  def run_test(content)
    current_line = 0
    current_method = nil

    require @file_path
    runner = nil
    if @line_number
      content.split("\n").each do |line|
        break if current_line > @line_number
        if /def +(test_[A-Za-z0-9_!?]*)/ =~ line
          current_method = Regexp.last_match(1)
        end
        current_line += 1
      end

      runner = Test::Unit::AutoRunner.new(false) do |runner|
        runner.filters << proc{|t| current_method == t.method_name ? true : false}
      end
    else
      runner = Test::Unit::AutoRunner.new(false)
    end
    runner.run
    puts "Running '#{current_method}' in file #{@file_path}"
  end

  def run_example
    cmd = nil
    ["script/spec", "vendor/plugins/rspec/bin/spec"].each do |spec_file|
      if File.exists?(spec_file)
        cmd = spec_file
        break
      end
    end
    cmd = (RUBY_PLATFORM =~ /[^r]win/) ? "spec.cmd" : "spec" unless cmd
    cmd << "#{@rspec_version} #{@file_path}"
    cmd << " --line #{@line_number}" if @line_number
    cmd << ' --backtrace' if @show_backtrace
    cmd << ' --drb' if @drb
    system cmd
  end
end

if $0 == __FILE__
  FocusedTest.run(*ARGV)
end
