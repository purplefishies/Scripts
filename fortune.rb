#!/usr/bin/env ruby

require 'fileutils'

def get_files(dir)
  Dir.open(dir).find_all { |i|
    File.file?("#{dir}/#{i}") && i=~/^(.*?\.txt|[A-z]+)$/ 
  }
end

def rand_quote(file)
  begin
    tmp = File.read(file).split(/^%/)

    #while (((keep= tmp[0]) =~ /^[\s\n]*\Z/ms) == 0 )
    # (0..tmp.length-1).each { |i| 
    while (((keep= tmp[(0..tmp.length-1).to_a.sample]) =~ /^[\s\n]*\Z/mx) == 0 )
    end
    keep.gsub!(/^[\s\n]*?(\[[^\]]+\])?[\s\n]*/x,'')
    keep = "\n" + keep + "\n"
    #puts "#{i}\t#{keep}"
    #puts "KEEP: #{keep}"
    #binding.pry
    #puts "HERE"
    #puts "KEEP: #{keep}"
    #return keep
    # }
    return keep
  rescue Exception => e
    puts e
  end
end

#puts rand_quote(#
#puts rand_quote(File.expand_path(ARGV[0]))
#rand_quote(File.expand_path(ARGV[0]))

puts rand_quote(ARGV.collect { |i|
  if File.file?(i)
    i
  elsif File.directory?(i)
    get_files(i).collect { |j| File.expand_path("#{i}/#{j}")}
  end
}.flatten.sample)
