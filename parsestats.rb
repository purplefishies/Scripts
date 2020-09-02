#!/usr/bin/env ruby

#
# Goal 1, find messages that aren't very consistent in their rates
#
#
require 'yaml'


def get_times(a)
   (0..a.length-2).collect { |i| a[i]["delivered_msgs"] / ( a[i]["window_stop"]["secs"] - a[i]["window_start"]["secs"] + a[i]["window_stop"]["nsecs"]*1e-9 - a[i]["window_start"]["nsecs"]*1e-9 ) }
end


stats = YAML.load_file(ARGV[0])
#puts stats

results = Hash.new {|h,v| h[v] = Hash.new }

stats.collect { |i| i["topic"] }.uniq.sort.each { |topic|
  t = stats.find_all { |i| i["topic"] == topic }
  times = get_times(t)
  results[topic]["mean"]  = times.reduce(&:+)/times.length
  sum_sqr = times.map {|x| x * x}.reduce(&:+)
  results[topic]["std_dev"] = Math.sqrt((sum_sqr - times.length * results[topic]["mean"] **2)/(times.length-1))
  #times.inject(0) { |s,v| s+= v } / times.length
}

#puts results
puts "---"
results.keys.sort { |a,b| results[b]["std_dev"] <=> results[a]["std_dev"] }.each { |key|
  puts "  - topic: #{key}"
  puts "    stddev: #{results[key]["std_dev"]}"
  puts "    mean: #{results[key]["mean"]}"
}



 
