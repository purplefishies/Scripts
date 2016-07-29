#!/usr/bin/ruby

require 'rubygems'
require 'chronic'
require 'optparse'
require 'fileutils'
require 'byebug'
# Default directory ENV["HOME"]/.bashcmd_history
#
# Date is current day
#
# 
#puts "FOOO"
if ARGV.empty?
  curtime = Chronic.parse("1 month ago")
else
  curtime = Chronic.parse(ARGV[0])
end

startdir = ENV["HOME"] + "/.bashcmd_history/"

catfiles = Dir.entries( startdir ).collect { |i| "#{startdir + i}" }.find_all { |f|
  if( !File.file?( f ) )
    false
  elsif f =~ /\d{4}_\d{2}$/
    false
  else 
    ["month","year"].collect { |i| File.stat( f ).mtime.send(i) } == ["month","year"].collect { |i| curtime.send(i) } 
  end
}

if !catfiles.empty?
  catfiles.sort! { |a,b| File.stat(a).mtime <=> File.stat(b).mtime }
  fp = File.open("#{startdir}bash_history_#{sprintf("%.2d",curtime.year)}_#{sprintf("%.2d",curtime.month)}","w")
  catfiles.each { |f|
    # lines = `cat #{f}`
    fp.write(`cat #{f}`)
  }

  fp.close()

  FileUtils.touch fp.path , :mtime => Date.new( curtime.year, curtime.month,1).to_time
end
