require 'rubygems'
require 'rspec'
require 'rspec/core/rake_task'
task :default => :spec

desc "Build Boris"
task :build do
  system "gem build boris.gemspec"
end

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w{--colour --format progress}
end