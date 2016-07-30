require "bundler/gem_tasks"
task :default => :spec

desc 'Run the specs'
task :spec do
  sh "rspec -fd spec/*.spec.rb"
end