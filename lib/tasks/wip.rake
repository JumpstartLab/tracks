Rake::TestTask.new([:test, :stats]) do |t|
  t.test_files = FileList[
    'test/functional/stats_controller_test.rb'
  ]
end

Rake::TestTask.new([:test, :lockdown]) do |t|
  t.test_files = FileList[
    'test/functional/lockdown_test.rb'
  ]
end

desc "run stats tests"
task :wip do
  Rake::Task['test:stats'].invoke
  Rake::Task['test:lockdown'].invoke
end

desc "run stats features"
namespace :cucumber do
  task :stats do
    sh "bundle exec cucumber features/show_statistics.feature"
  end
end
