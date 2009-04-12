require "#{File.dirname(__FILE__)}/spec_helper"

describe FocusedTest do
  describe "#run" do
    context "when passed in file has a test in it" do
      it "runs the focused test" do
        output = `ruby #{dir}/../lib/focused_test.rb --file #{dir}/fixtures/fixture_test.rb --line 5`
        output.should include("test_1")
        output.should_not include("test_2")
      end
    end

    context "when passed a filepath that ends with _spec.rb" do
      it "runs the focused spec" do
        output = `ruby #{dir}/../lib/focused_test.rb --file #{dir}/fixtures/fixture_spec.rb --line 5`
        output.should include("does something 1")
        output.should_not include("does something 2")
      end
    end

    def dir
      File.dirname(__FILE__)
    end
  end
end