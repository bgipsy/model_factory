require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'active_record/base'
require 'rspec/core/rake_task'

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
end

task :prepare_sqlite do
  ENV['ADAPTER'] = 'sqlite'
  require './spec/support/db_schema.rb'
  SQLiteDatabase.prepare_database
end

task :prepare_postgres do
  ENV['ADAPTER'] = 'postgres'
  require './spec/support/db_schema.rb'
  PostgresDatabase.prepare_database
end

task :spec_sqlite => [:prepare_sqlite, :spec]
task :default => [:prepare_postgres, :spec]
