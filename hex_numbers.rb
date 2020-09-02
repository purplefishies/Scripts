#!/usr/bin/env ruby

while true
   val = 2**rand(16)
  puts sprintf "What is %#x",val
  tmp = readline
  tmp.chomp!
  if tmp.to_i != val
    puts "incorrect: #{val}" 
  else 
    puts "correct"
  end
end
