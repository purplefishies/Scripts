#!/usr/bin/ruby

require 'rubygems'
require 'chronic'
require 'optparse'

# Default directory ENV["HOME"]/.bashcmd_history
#
# Date is current day
#
# 

curtime = Chronic.parse("1 month ago")
startdir = ENV["HOME"] + "/.bashcmd_history/"

catfiles = Dir.entries( startdir ).collect { |i| "#{startdir + i}" }.find_all { |f|
  if( !File.file?( f ) )
    false
  else 
    ["month","year"].collect { |i| File.stat( f ).mtime.send(i) } == ["month","year"].collect { |i| curtime.send(i) } 
  end
}

catfiles.sort! { |a,b| File.stat(a).mtime <=> File.stat(b).mtime }

fp = File.open("#{startdir}/hist_.bashhistory_#{sprintf("%.2d",curtime.month)}_#{curtime.year}","w")

catfiles.each { |f|
  fp.write(`cat #{f}`)
}

fp.close()

