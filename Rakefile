namespace :redis do
  desc "Updates the Redis database"
  task :update do
    require "main"
    push_to_redis
  end

  desc "Compresses dump.rdb"
  task :compress => %w(dump.rdb.tar.gz)
end

task "dump.rdb.tar.gz" => "dump.rdb" do |t|
  sh "tar czfv #{t.name} #{t.prerequisites.join(' ')}"
end

task "dump.rdb" do |t|
  sh "cd ../ezmobius-redis-rb-0.1.1 && rake redis:stop || exit 0"
  sh "cp ../ezmobius-redis-rb-0.1.1/dump.rdb #{t.name}"
end

task "results.txt" => %w(main.rb) do
  rm_f "results.txt"
  sh "ruby -rubygems main.rb > results.txt"
end

desc "Recalculates results.txt"
task :results => "results.txt"
task :default => :results
