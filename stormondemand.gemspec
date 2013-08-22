# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "Storm/version"

Gem::Specification.new do |s|
  s.name        = "stormondemand"
  s.version     = Storm::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Caige Nichols"]
  s.email       = ["cnichols@liquidweb.com"]
  s.homepage    = "http://github.com/liquidweb/ruby-stormondemand"
  s.license     = "Apache 2.0"
  s.summary     = %q{A Ruby client library for the Storm On Demand Cloud API.}
  s.description = %q{A Ruby client library for the Storm On Demand Cloud API.}

  s.rubyforge_project = "StormOnDemand"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "excon",
    [">= 0.20.1"]
  s.add_runtime_dependency "json"
  s.add_development_dependency "yard"
end
