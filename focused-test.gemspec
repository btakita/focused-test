# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{focused-test}
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Takita"]
  s.date = %q{2009-08-29}
  s.default_executable = %q{focused-test}
  s.email = %q{brian.takita@gmail.com}
  s.executables = ["focused-test"]
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "CHANGES",
    "README",
    "Rakefile",
    "VERSION.yml",
    "bin/focused-test",
    "lib/focused_test.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/technicalpickles/jeweler}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Script to run a focused test or spec.}
  s.test_files = [
    "spec/focused_test_spec.rb",
    "spec/spec_helper.rb",
    "spec/fixtures/fixture_test.rb",
    "spec/fixtures/fixture_spec.rb",
    "spec/fixtures/fixture_shoulda.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
