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

hsh = {}

if !catfiles.empty?
  catfiles.sort! { |a,b| File.stat(a).mtime <=> File.stat(b).mtime }
  fp = File.open("#{startdir}bash_history_#{sprintf("%.2d",curtime.year)}_#{sprintf("%.2d",curtime.month)}","w")
  catfiles.each { |f|
    begin
      fp2  = File.open(f)
      while line = fp2.gets
        if line =~ /^(\#\d+\s*)$/ 
          nline = fp2.gets
          hsh[$1] = nline
        else
          next
        end
      end
    rescue Exception => e 
      puts "#{e}...skipping file #{f}"
      next
    end
    #lines = `cat #{f}`
    #fp.write(`cat #{f}`)
  }
  hsh.keys.sort.each { |i| 
    fp.write( i )
    fp.write( hsh[i] )
  }

  fp.close()

  FileUtils.touch fp.path , :mtime => Date.new( curtime.year, curtime.month,1).to_time
end
