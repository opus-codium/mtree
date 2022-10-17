# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'github_changelog_generator/task'

RSpec::Core::RakeTask.new(:spec)

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.user = 'opus-codium'
  config.project = 'mtree'
  config.exclude_labels = ['skip-changelog']
  config.future_release = "v#{Mtree::VERSION}"
  config.since_tag = 'v1.0.0'
end

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
