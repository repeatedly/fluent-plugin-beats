# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "fluent-plugin-beats"
  gem.description = "Elastic beats plugin for Fluentd event collector"
  gem.license     = "Apache-2.0"
  gem.homepage    = "https://github.com/repeatedly/fluent-plugin-beats"
  gem.summary     = gem.description
  gem.version     = File.read("VERSION").strip
  gem.authors     = ["Masahiro Nakagawa"]
  gem.email       = "repeatedly@gmail.com"
  gem.has_rdoc    = false
  #gem.platform    = Gem::Platform::RUBY
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency "fluentd", [">= 0.10.58", "< 2"]
  gem.add_dependency "concurrent-ruby", [">= 0.9.2", "< 2"]
  gem.add_development_dependency "rake", ">= 0.9.2"
  gem.add_development_dependency "test-unit", ">= 3.0.8"
  gem.add_development_dependency "test-unit-rr", ">= 1.0.3"
end
