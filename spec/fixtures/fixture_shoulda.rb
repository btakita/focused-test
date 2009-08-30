require 'rubygems'
require 'shoulda'

class FixtureShouldaTest < Test::Unit::TestCase
  context "fixture test with shoulda" do
    should "do something 1" do
      puts "does something 1"
    end

    should "do something 2" do
      puts "does something 2"
    end

    context "I am a context" do
      should "run this whole context" do
        puts "context 1"
      end

      should "be run this whole context" do
        puts "context 2"
      end
    end
  end
end
