require "bundler/gem_tasks"
require "rake/testtask"
require "yard"
require "mail_to_hip_chat"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/{unit,integration}/**/*_test.rb']
  t.verbose = true
end

YARD::Rake::YardocTask.new do |t|
  t.options += ['--title', "Mail To HipChat #{MailToHipChat::VERSION} Documentation"]
end

task :default => :test