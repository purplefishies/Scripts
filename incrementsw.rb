#!/usr/bin/env ruby

tags = IO.popen("git tag -l").readlines.find_all { |i| i =~ /\d+\.\d+/ }.collect { |i| i.chomp! }

def blah(x) 
  x.sub(/^v/,'').sub(/(\d+)\.(\d+)/,'\1'*4 + '\2' ).to_i
end

tags.sort! { |x,y|  blah(x) <=> blah(y) }

puts tags.last.sub(/^v/,'').sub(/(\d+)\.(\d+)/) { "v#{$1}." + ($2.to_i + 1).to_s }

