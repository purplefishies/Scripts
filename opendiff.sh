#!/usr/bin/env ruby

(0..8).each { |i|
     puts "#{i} #{ARGV[i]}"
}

puts "HERE"

old = ARGV[0]
tmp = Dir.pwd()
tmp.sub!(/^(.*?)#{File.dirname(old)}/,'\1')
tmp = "/" + tmp
tmp += "/" + old

diff_app = ( ENV["DIFF_APP"].nil?  ? "tkdiff" : ENV["DIFF_APP"] )
puts "#{diff_app} #{ARGV[1]} #{tmp} "
exec "#{diff_app} #{ARGV[1]} #{tmp} "
