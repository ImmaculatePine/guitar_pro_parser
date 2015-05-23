# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guitar_pro_parser/version'

Gem::Specification.new do |spec|
  spec.name          = 'guitar_pro_parser'
  spec.version       = GuitarProParser::VERSION
  spec.authors       = ['Alexander Borovykh']
  spec.email         = ['immaculate.pine@gmail.com']
  spec.description   = %q{Gem for reading Guitar Pro files}
  spec.summary       = %q{This gem allows to read Guitar Pro files. Now it supports Guitar Pro 4 and 5 files. Version 3 should work but is not tested at all.}
  spec.homepage      = 'https://github.com/ImmaculatePine/guitar_pro_parser'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.2.0'
  spec.add_development_dependency 'rspec-its', '~> 1.2.0'

end
