#!/usr/bin/env ruby

tmp = File.readlines(ARGV[0]).collect { |i| i.chomp!; File.stat(i) }.sort { |x,y| x.mtime <=> y.mtime }
puts "In: #{tmp.first.mtime}:  \nOut: #{tmp.last.mtime}"
