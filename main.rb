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

def tids
  @tids ||= File.read("data/test.txt").split("\n").map {|n| n.to_i}
end

def main
  srand(1_048_576)
  max_rid = rids.last
  tids.each do |tid|
    recommendations = (1..10).inject([]) {|memo, _| memo << 1 + rand(max_rid)}
    puts "#{tid}:#{recommendations.join(',')}"
  end
end

main if __FILE__ == $0
