# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task build: :gen_parser
task spec: :gen_parser

desc "Generate the mtree parser's code"
task gen_parser: [
  'lib/mtree/parser.tab.rb',
]

file 'lib/mtree/parser.tab.rb' => 'lib/mtree/parser.y' do
  sh 'racc -S lib/mtree/parser.y'
end
