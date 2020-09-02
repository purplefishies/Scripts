#!/usr/bin/env ruby

require 'rubygems'
require 'rake'
require 'chronic'

LEARNING_DIR = File.expand_path( ENV["LEARNING_DIR"] )
ARCHIVE_DIR  = File.expand_path(LEARNING_DIR + "/Archive/" )
REVIEW_DIR   = File.expand_path(LEARNING_DIR + "/Review/" )
TODAY_DIR = File.expand_path( REVIEW_DIR + "/" + Chronic.parse("today").strftime("%Y/%b/%d"))
YESTERDAY_DIR = File.expand_path( REVIEW_DIR + "/" + Chronic.parse("yesterday").strftime("%Y/%b/%d"))

mkdir_p TODAY_DIR
mkdir_p YESTERDAY_DIR

# sh "$HOME/Scripts/find.pl #{LEARNING_DIR} -before today -after yesterday -type f -maxdepth 1 -print0 2>/dev/null | xargs -I{} -0 mv {} $HOME/Projects/Learning/Archive/$(date \"+%Y/%b/%d\" -d \"yesterday\")"
#files = `find #{LEARNING_DIR} -path ./Archive -prune -o -path ./Review -prune -o -type f -maxdepth 1`.split("\n")
files = `find #{LEARNING_DIR} -path ./Archive -prune -o -path ./Review -prune -o -path ./.git -prune -o  -type f -newermt `

newfiles = files.find_all { |i|
  i !~ /_region/ && 
  i !~ /\.(out|aux|log)/ 
}

rm_rf([ Dir.glob( File.expand_path( "#{REVIEW_DIR}/last_week") + "/*"),
        Dir.glob( File.expand_path( "#{REVIEW_DIR}/last_two_weeks") + "/*"),
        Dir.glob( File.expand_path( "#{REVIEW_DIR}/last_month") + "/*"),
        Dir.glob( File.expand_path( "#{REVIEW_DIR}/two_months_ago") + "/*"),
        Dir.glob( File.expand_path( "#{REVIEW_DIR}/three_months_ago") + "/*"),
        Dir.glob( File.expand_path( "#{REVIEW_DIR}/last_year") + "/*"),
      ])

files.each { |file|
  mkdir_p( ARCHIVE_DIR + "/" + File.stat(file).mtime.strftime("%Y/%b/%d"))
  mv( file, ARCHIVE_DIR + "/" + File.stat(file).mtime.strftime("%Y/%b/%d") )
}
       
if true
puts "Updating Weekly"
files = `find.pl #{ARCHIVE_DIR} -after \"1 week ago\" -type f`.split("\n")
ln_s(files,"#{REVIEW_DIR}/last_week",:force => true )

puts "Updating BiWeekly"
files = `find.pl #{ARCHIVE_DIR} -after \"2 weeks ago\" -type f`.split("\n")
ln_s(files,"#{REVIEW_DIR}/last_two_weeks",:force => true )

puts "Updating Monthly"
files = `find.pl #{ARCHIVE_DIR} -after \"1 month ago\" -type f`.split("\n")
ln_s(files,"#{REVIEW_DIR}/last_month",:force => true )

puts "Updating Two Months Ago"
files = `find.pl #{ARCHIVE_DIR} -after \"2 months ago\" -type f`.split("\n")
ln_s(files,"#{REVIEW_DIR}/two_months_ago",:force => true )

puts "Updating Three Months Ago"
files = `find.pl #{ARCHIVE_DIR} -after \"3 months ago\" -type f`.split("\n")
ln_s(files,"#{REVIEW_DIR}/three_months_ago",:force => true )

puts "Updating Yearly"
files = `find.pl #{ARCHIVE_DIR} -after \"1 year ago\" -type f`.split("\n")
ln_s(files,"#{REVIEW_DIR}/last_year",:force => true )

end
