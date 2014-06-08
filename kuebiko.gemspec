# -*- encoding: utf-8 -*-

require File.expand_path('../lib/kuebiko/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'kuebiko'
  gem.version     = Kuebiko::VERSION
  gem.authors     = ['David Ramalho']
  gem.email       = ['dramalho@gmail.com']
  gem.description = 'Ruby SDK to develop Kuebiko nodes'
  gem.summary     = gem.description
  gem.homepage    = 'https://gitlab.com/kuebiko/ruby-kuebiko'  # Yes, git*LAB* :)
  gem.license     = 'MIT'

  gem.require_paths    = ['lib']
  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- {spec}/*`.split("\n")
  gem.extra_rdoc_files = %w(LICENSE README.md TODO.md)

  gem.add_dependency('virtus', '~> 1.0.2')
  gem.add_dependency('hashie', '~> 2.1')
  gem.add_dependency('mosquitto')
  gem.add_dependency('celluloid')
end
