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
    strategy_for_file.call    
  end

  private
  def strategy_for_file
    if @file_path =~ /\.feature/
      return proc { run_feature }
    elsif @file_path =~ /spec\.rb/
      return proc { run_example }
    end
    
    content = IO.read(@file_path)
    if content =~ /class .*Test < (.*TestCase|ActionController::IntegrationTest)/
      if content =~ /should\s+['"].*['"]\s+do/
        return proc { run_should content }
      else
        return proc { run_test content }
      end
    end
  end

  protected
  def parse(args)
    @file_path = nil
    @line_number = nil
    @format = nil
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
      
      o.on('-F', '--format=FORMAT', String, "Output formatter for rspec or cucumber") do |format|
        @format = format
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
    puts "Running '#{current_method}' in file #{@file_path}" unless current_method.nil?
  end

  def run_should(content)
    unless @line_number
      return run_test(content)
    end

    require @file_path

    should, context, description = '', '', ''
    
    content   = content.split("\n")
    lines     = content[0...@line_number].reverse
    context   = lines.find { |line| line =~ /^\s*context\b/ }

    unless content[@line_number - 1] =~ /^\s*context\b/
      should = parse_from_quotes(lines.find { |line| line =~ /^\s*should\b/ })
    end

    if !context.empty?
      context = parse_from_quotes( context )
      description = should.empty? ? context : "#{context} should #{should}"
      method_regex = description.gsub(/[\+\.\s\'\"\(\)]/,'.')

      runner = Test::Unit::AutoRunner.new(false) do |runner|
        runner.filters << proc{|t| t.method_name.match(method_regex) ? true : false }
      end

      runner.run

      puts "Running '#{description}' in file #{@file_path}" unless description.empty?
    end
  end
  
  def run_example
    if File.exist?('.rspec')
      cmd = `which rspec`.strip
    else
      cmd = ["script/spec", "vendor/plugins/rspec/bin/spec", "/usr/bin/spec"].find {|script| File.exist?(script) }
    end
    
    cmd = (RUBY_PLATFORM =~ /[^r]win/) ? "spec.cmd" : "spec" unless cmd
    cmd << "#{@rspec_version} #{@file_path}"
    cmd << " --line #{@line_number}" if @line_number
    cmd << ' --backtrace' if @show_backtrace
    cmd << ' --drb' if @drb
    cmd << " --format #{@format ? @format : 'progress'}"
    system cmd
  end
  
  def run_feature
    cmd = ""
    ["script/cucumber", `which cucumber`.strip, "/usr/bin/cucumber"].each do |cucumber_executable|
      if File.exists?(cucumber_executable)
        cmd = cucumber_executable
        break
      end
    end
    
    cmd << " #{@file_path}"
    cmd << ":#{@line_number}" if @line_number
    cmd << " --format #{@format ? @format : 'pretty'}"

    system cmd  
  end

  def parse_from_quotes(name)
    name.to_s.gsub(/^(?:.*"(.*)"|.*'(.*)').*$/) { $1 || $2 }
  end
end
