Gem::Specification.new do |s|
  s.name        = "model_factory"
  s.version     = "0.1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Serge Balyuk"]
  s.email       = ["serge@complicated-simplicity.com"]
  s.homepage    = "http://github.com/bgipsy/model_factory"
  s.summary     = "ActiveRecord model factory to be used with tests"
  s.description = "model_factory aim is flexibility in handling ActiveRecord associations: it eases instantiation of models with complex dependencies"
 
  s.required_rubygems_version = ">= 1.3.6"
 
  s.add_development_dependency "rspec", "~> 2.5.0"
  s.add_development_dependency "sqlite3-ruby", "~> 1.3.2"
  
  s.add_dependency "activerecord", "~> 3.0.4"
 
  s.files        = Dir.glob("{lib}/**/*") + Dir.glob("{spec}/**/*") + %w(MIT-LICENSE README.md Rakefile Gemfile)
  s.require_path = 'lib'
end
