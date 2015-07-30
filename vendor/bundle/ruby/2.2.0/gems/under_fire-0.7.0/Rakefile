require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib/under_fire'
  t.test_files = FileList['spec/lib/under_fire/*_spec.rb']
  t.verbose = true
end

task :default => :test
