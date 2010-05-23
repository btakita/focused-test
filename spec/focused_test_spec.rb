require "#{File.dirname(__FILE__)}/spec_helper"

describe FocusedTest do
  describe "#run" do
    context "when passed in file has a test in it" do
      before { @file = "#{dir}/fixtures/fixture_test.rb" }

      context "when passed a --line" do
        it "runs the focused test" do
          output = run_test("-f #{@file} -l 5")
          output.should include("test_1")
          output.should_not include("test_2")
        end
      end

      context "when not passed a --line" do
        it "runs the entire test" do
          output = run_test("-f #{@file}")
          output.should include("test_1")
          output.should include("test_2")
        end
      end
    end

    context "when passed in file has a shoulda test in it" do
      before { @file = "#{dir}/fixtures/fixture_shoulda.rb" }

      context "when passed a --line" do
        context "at the head of a context block" do
          it "runs the focused context" do
            output = run_test("-f #{@file} -l 14")
            output.should include("context 1")
            output.should include("context 2")
            output.should_not include("does something 1")
            output.should_not include("does something 2")
          end
        end

        context "at the head or inside of a should block" do
          it "runs the focused should" do
            output = run_test("-f #{@file} -l 7")
            output.should include("does something 1")
            output.should_not include("does something 2")
          end
        end
      end

      context "when not passed a --line" do
        it "runs the entire test" do
          output = run_test("-f #{@file}")
          output.should include("does something 1")
          output.should include("does something 2")
          output.should include("context 1")
          output.should include("context 2")
        end
      end
    end

    context "when passed a filepath that ends with _spec.rb" do
      before { @file = "#{dir}/fixtures/fixture_spec.rb" }

      context "when passed a --line" do
        it "runs the focused spec" do
          output = run_test("-f #{@file} -l 5")
          output.should include("does something 1")
          output.should_not include("does something 2")
        end
      end

      context "when not passed a --line" do
        it "runs the entire spec" do
          output = run_test("-f #{@file}")
          output.should include("does something 1")
          output.should include("does something 2")
        end
      end
    end

    context "when passed a filepath that ends with .feature" do          
      before do
        features_path = File.expand_path("#{dir}/fixtures/features/")
        @file = "#{features_path}/focused-test.feature"
      end
      
      context "when passed a --line" do
        it 'runs the focused scenario' do
          output = run_test("-f #{@file} -l 6") 
          output.should include("does something 1")
          output.should_not include("does something 2")
          output.should include("1 scenario (1 passed)")
          output.should include("1 step (1 passed)")
        end
      end
      
      context "when not passed a --line" do
        it "runs the entire feature file" do
          output = run_test("-f #{@file}")
          output.should include("does something 1")
          output.should include("does something 2")
          output.should include("2 scenarios (2 passed)")
          output.should include("2 steps (2 passed)")
        end
      end
    end
    
    def dir
      File.dirname(__FILE__)
    end

    def run_test(command_line)
      `ruby -e "require '#{dir}/../lib/focused_test'; FocusedTest.run('#{command_line.split(/\s/).join(%q[','])}')"`
    end
  end
end
