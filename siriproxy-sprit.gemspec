# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-sprit"
  s.version     = "0.0.1" 
  s.authors     = ["michael ullrich"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{An simple plugin for Austria Gas-Prices}
  s.description = %q{shows the 5 cheapes gas-stations in your vicinity in Austria }

  s.rubyforge_project = "siriproxy-sprit"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "eat"
#   s.add_runtime_dependency "timeout"
end
