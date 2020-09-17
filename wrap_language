#!/bin/bash

#
exec ${RUBY-ruby}  -0400  -x "$0" "$@"

#!ruby
cmd = ""
if ARGV[0] == "" 
  cmd = "bash"
else
  cmd = ARGV[0]
end

while line = STDIN.gets 
  #puts line
  puts "```#{cmd}\n" + line  + "\n```";
end
