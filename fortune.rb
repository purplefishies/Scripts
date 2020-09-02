#!/usr/bin/env ruby

require 'fileutils'
def get_files(dir)
  Dir.open(dir).find_all { |i|
    File.file?("#{dir}/#{i}") && i=~/^(.*?\.txt|[A-z]+)$/ 
  }
end

def rand_quote(file)
  begin
    while (((tmp = File.read(file).split(/^%/).sample) =~ /^\s*$/) != 0 )
    end
    return tmp
  rescue Exception => e
  end
end

#puts rand_quote(#

puts rand_quote(ARGV.collect { |i|
  if File.file?(i)
    i
  elsif File.directory?(i)
    get_files(i).collect { |j| File.expand_path("#{i}/#{j}")}
  end
}.flatten.sample)
