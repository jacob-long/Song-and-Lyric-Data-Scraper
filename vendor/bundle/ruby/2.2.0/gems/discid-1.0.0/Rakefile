require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yard'

desc "Run just the unit tests"
Rake::TestTask.new(:test) do |test|
  test.test_files = FileList['test/test*.rb']
  test.libs = ['lib', 'ext']
  test.warning = true
end

YARD::Rake::YardocTask.new do |t|
end