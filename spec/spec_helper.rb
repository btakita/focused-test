dir = File.dirname(__FILE__)
require "rubygems"
$LOAD_PATH.unshift(File.expand_path("#{File.dirname(__FILE__)}/../lib"))
require "focused_test"
require "spec"
require "spec/autorun"
require "rr"

Spec::Runner.configure do |config|
  config.mock_with :rr
end

