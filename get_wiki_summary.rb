#!/usr/bin/env ruby


require 'rubygems'
require 'haml'
require 'nokogiri'
require 'open-uri'



if ARGV.length == 0 
  STDERR.puts "Usage:  #{$0} wikipage1 [wikipage2 ...]"
end

fp = File.open("wikirevised.txt","w")

ARGV.each { |url|
  puts "Page: #{url}"
  page = Nokogiri::HTML(open(url))   
  fp.puts URI.unescape(url).sub(/.*wiki\/(\S+.*)$/,'\1')
  fp.puts "\n"
  fp.puts page.xpath('//*[@id="mw-content-text"]/p[1]').text 
  fp.puts "\n\n"
}
fp.close
