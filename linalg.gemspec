# -*- encoding: utf-8 -*-
require File.expand_path("../lib/linalg/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "linalg"
  s.version     = Linalg::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["James M. Lawrence"]
  s.email       = ["quixoticsycophant@gmail.com"]
  s.homepage    = "http://github.com/quix/linalg"
  s.summary     = "Ruby Linear Algebra Library"
  s.description = "A Fortran-based linear algebra package"

  s.required_rubygems_version = ">= 1.3.6"

  s.rubyforge_project = "linalg"

  s.files = Dir["{lib}/**/*.rb", "{ext}/**/*.{c,h,rb,tmpl}", "LICENSE", "*.md"]
  s.extensions = ['ext/lapack/extconf.rb', 'ext/linalg/extconf.rb']
end
