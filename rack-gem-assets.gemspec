# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rack/gem_assets/version"

Gem::Specification.new do |s|
  s.name        = "rack-gem-assets"
  s.version     = Rack::GemAssets::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Simon Menke"]
  s.email       = ["simon.menke@gmail.com"]
  s.homepage    = "http://github.com/fd/rack-gem-assets"
  s.summary     = %q{Load assets from gems}
  s.description = %q{A Middleware for sending assets packaged in loaded gems}

  s.rubyforge_project = "rack-gem-assets"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency 'rack'
  
end
