# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = 'stronger_parameters'
  s.version     = '0.2.0'
  s.summary     = "Rails Parameter validation"
  s.description = "Rails Parameter validation"
  s.authors     = ["Trek Glowacki"]
  s.email       = 'trek.glowacki@gmail.com'
  s.files       = `git ls-files`.split($\)
  s.homepage    = 'http://github.com/trek/stronger_params'
  s.require_paths = ["lib"]

  s.add_dependency                 'activemodel'

  s.add_development_dependency     'rspec'
  s.add_development_dependency     'pry'

end
