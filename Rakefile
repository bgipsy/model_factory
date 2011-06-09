require 'rubygems'
require 'bundler/setup'

require 'rspec/core/rake_task'
require 'active_record'

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
end

task :db_prepare do
  require './spec/support/db_schema.rb'
  CreateTestSchema.prepare_database
end

task :default => [:db_prepare, :spec]
