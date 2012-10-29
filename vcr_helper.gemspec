# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vcr_helper/version'

Gem::Specification.new do |gem|
  gem.name          = "vcr_helper"
  gem.version       = VcrHelper::VERSION
  gem.authors       = ["Josh Sharpe"]
  gem.email         = ["josh.m.sharpe@gmail.com"]
  gem.description   = %q{makes vcr easier to use}
  gem.summary       = %q{makes vcr easier to use}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
