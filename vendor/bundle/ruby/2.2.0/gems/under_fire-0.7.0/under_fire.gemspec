 # coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'under_fire/version'
require 'rbconfig'

Gem::Specification.new do |spec|
  spec.name          = "under_fire"
  spec.version       = UnderFire::VERSION
  spec.authors       = ["Jason Thompson"]
  spec.email         = ["jason@jthompson.ca"]
  spec.description   = %q{An unofficial wrapper for the Gracenote web API}
  spec.summary       = %q{An unofficial wrapper for the Gracenote web API}
  spec.homepage      = "http://github.com/jasonthompson/under_fire"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   << 'under-fire'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry-plus"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "guard-minitest"
  spec.add_development_dependency "rr"
  spec.add_development_dependency "minitest-doc_reporter", "~> 0.6.0"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "ox"
  if RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwi/
    spec.add_development_dependency "wdm", ">= 0.1.0"
  end

  spec.add_runtime_dependency "builder"
  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "nori"
  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "discid"
end
