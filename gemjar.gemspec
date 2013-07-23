# -*- encoding: utf-8 -*-
require File.expand_path('../lib/gemjar/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Vincent Batts"]
  gem.email         = ["vbatts@redhat.com"]
  gem.description   = %q{Create java jar, for jRuby, from gems or a bundler Gemfile}
  gem.summary       = %q{Create java jar, for jRuby, from gems or a bundler Gemfile}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "gemjar"
  gem.require_paths = ["lib"]
  gem.version       = Gemjar::VERSION
end
