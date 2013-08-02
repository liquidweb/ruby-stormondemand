# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "Storm/version"

Gem::Specification.new do |s|
  s.name        = "Storm"
  s.version     = Storm::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Eric Wong"]
  s.email       = ["ericsyw@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A Ruby client library for the Storm On Demand Cloud API.}
  s.description = %q{A Ruby client library for the Storm On Demand Cloud API.}

  s.rubyforge_project = "Storm"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
