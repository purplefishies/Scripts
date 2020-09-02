#!/usr/bin/env ruby
require 'fileutils'

fp = File.open(ARGV[0])
prev_file = nil
hsh = Hash.new { |k,v| k[v] = [] }
fp.each_line { |l|
  if l =~ /^\s*\#.*/
    next
  end
  if l =~ /^DUPTYPE_FIRST_OCCURRENCE.*?(\.\/.*)$/
    prev_file = $1
    
  elsif l =~ /^DUPTYPE_WITHIN_SAME_TREE.*?(\.\/.*)$/
    hsh[prev_file].push($1)
  end
}

hsh.keys.each { |file|
  puts "Processing #{file}"
  hsh[file].each { |subfile|
    puts "\tUnlinking #{subfile}"
    begin 
      # File.unlink(subfile)
      # File.symlink(File.expand_path(file), File.expand_path(subfile))
      FileUtils.ln_s( File.expand_path(file) , File.expand_path(subfile), :force => true )
      sleep(0.02)
    rescue Exception => e 
      puts "Issue was #{e}"
    end
  }
}

#puts hsh.keys.length
