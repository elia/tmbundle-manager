# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tmbundle/manager/version'

Gem::Specification.new do |spec|
  spec.name          = 'tmbundle-manager'
  spec.version       = Tmbundle::Manager::VERSION
  spec.authors       = ['Elia Schito']
  spec.email         = ['elia@schito.me']
  spec.summary       = %q{TextMate 2 Bundle/Package Manager}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'thor'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'spectator', '~> 1.3'
end
