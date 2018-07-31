$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pulitzer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pulitzer"
  s.version     = Pulitzer::VERSION
  s.authors     = ["Gk Parish-Philp", "Michael Ferguson"]
  s.email       = ["gk@gkparishphilp.com"]
  s.homepage    = "http://gkparishphilp.com"
  s.summary     = "Pulitzer is a CMS for Rails."
  s.description = "Pulitzer is a CMS for Rails."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.6"

  s.add_dependency "acts-as-taggable-array-on"
  s.add_dependency "awesome_nested_set", '~> 3.1'
  s.add_dependency "carrierwave"
  s.add_dependency 'coffee-rails', '~> 4.2.2'
  s.add_dependency "devise"
  s.add_dependency "fog-aws"
  s.add_dependency "friendly_id", '~> 5.1.0'
  s.add_dependency "haml"
  s.add_dependency 'jquery-rails'
  s.add_dependency 'jquery-ui-rails'
  s.add_dependency "kaminari"
  s.add_dependency "pg"
  s.add_dependency "pundit"
  # TODO s.add_dependency 'paper_trail', '~> 3.0.1'
  s.add_dependency 'route_downcaser'
  s.add_dependency 'sass-rails', '~> 5.0'
  s.add_dependency 'sitemap_generator'


  s.add_development_dependency "sqlite3"
end
