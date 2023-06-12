# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid_ability/version'

Gem::Specification.new do |spec|
  spec.name          = 'mongoid_ability'
  spec.version       = MongoidAbility::VERSION
  spec.authors       = ['Tomas Celizna']
  spec.email         = ['tomas.celizna@gmail.com']
  spec.summary       = 'Custom Ability class that allows CanCanCan authorization library store permissions in MongoDB via the Mongoid gem.'
  spec.description   = 'Custom Ability class that allows CanCanCan authorization library store permissions in MongoDB via the Mongoid gem.'
  spec.homepage      = 'https://github.com/tomasc/mongoid_ability'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'cancancan', '~> 2.2'
  spec.add_dependency 'mongoid', '~> 7.0', '>= 7.0.2'

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'database_cleaner-mongoid', '~> 2.0.1'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake', '~> 13.0'
end
