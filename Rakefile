require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Generate the mtree parser's code"
task :parser do
  sh 'racc lib/mtree/parser.y'
end
