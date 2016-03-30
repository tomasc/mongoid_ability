# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid_ability/version'

Gem::Specification.new do |spec|
  spec.name          = "mongoid_ability"
  spec.version       = MongoidAbility::VERSION
  spec.authors       = ["Tomáš Celizna"]
  spec.email         = ["tomas.celizna@gmail.com"]
  spec.summary       = %q{Custom Ability class that allows CanCanCan authorization library store permissions in MongoDB via the Mongoid gem.}
  spec.description   = %q{Custom Ability class that allows CanCanCan authorization library store permissions in MongoDB via the Mongoid gem.}
  spec.homepage      = "https://github.com/tomasc/mongoid_ability"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "cancancan", "~> 1.9"
  spec.add_dependency "mongoid", "~> 5"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "database_cleaner", ">= 1.5.1"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-minitest"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"
end
