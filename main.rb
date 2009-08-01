require "active_support"

# Returns Hash of {uid => [rids]}
def uids_to_rids
  @uids_to_rids ||= File.read("data/data.txt").split("\n").map {|line| line.split(":")}.map {|a| a.map {|n| n.to_i}}.inject(Hash.new {|h,k| h[k] = []}) do |memo, (uid, rid)|
    memo[uid] << rid
    memo
  end
end

def rids
  @rids ||= File.read("data/repos.txt").split("\n").map {|line| line.split(":", 2).first}.map {|n| n.to_i}.sort
end

def repos
  @repos ||= File.read("data/repos.txt").split("\n").map {|line| line.split(":").map {|datum| datum.split(",")}.flatten}.inject(Hash.new) do |memo, data|
    repo = Hash.new
    repo[:name]    = data[1]
    repo[:created] = data[2]
    repo[:parent]  = data[3] if data[3]

    memo[data.first.to_i] = repo
    memo
  end
end

def tids
  @tids ||= File.read("data/test.txt").split("\n").map {|n| n.to_i}
end

def push_to_redis
  require "redis"
  require "json"

  redis = Redis.new
  redis.flushdb
  puts "Pushing watches"
  redis.pipelined do |p|
    uids_to_rids.each do |uid, rids|
      rids.each do |rid|
        p.sadd "#{uid}:watches", rid.to_s
      end
    end
  end

  puts "Pushing test UIDs"
  redis.pipelined do |p|
    tids.each do |tid|
      p.sadd "test", tid.to_s
    end
  end

  puts "Pushing repository data"
  redis.pipelined do |p|
    repos.each do |id, attrs|
      p.set "repo:#{id}", attrs.to_json
    end
  end
end

def main
  srand(2*1_048_576)
  max_rid = rids.last
  tids.each do |tid|
    recommendations = (1..10).inject([]) {|memo, _| memo << 1 + rand(max_rid)}
    puts "#{tid}:#{recommendations.join(',')}"
  end
end

main if __FILE__ == $0
