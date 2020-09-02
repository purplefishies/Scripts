#!/usr/bin/env ruby

require 'chronic'


time = Chronic.parse(ARGV[0]) || Chronic.parse("1 month ago")

if ARGV[1].nil?
  format = "%Y_%m"
else
  format = ARGV[1]
end

puts time.strftime( format )
