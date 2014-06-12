# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require 'capistrano/commons/version'

Gem::Specification.new do |s|
  s.name          = "capistrano-commons"
  s.version       = Capistrano::Commons::VERSION
  s.authors       = ["Anthony Powles"]
  s.email         = ["rubygems+capistrano-commons@idreamz.net"]
  s.homepage      = "https://github.com/yogin/capistrano-commons"
  s.summary       = %q{Capistrano Common Recipes}
  s.description   = %q{A collection of useful Capistrano recipes}
  s.license       = "MIT"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"

  s.add_dependency "capistrano", ">= 2.14.2"
end
