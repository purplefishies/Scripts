#!/usr/bin/ruby


require 'nt.rb'
j = -3 ; a = (1..4).map { j+= 4; (j..j+3).to_a }



#b = KnightsTour.new( a )
c =  KnightsTour.new( (1..4).map { Array.new(4) } )
c.board[1][1] = 6
c.board[0][3] = 4

#puts c.to_s

puts "Trials"
#puts "(1,1): #{c.searchPos(1,1)}"
puts "(2,3): #{c.searchPos(2,3)}"

c.board[2][3] = 11


puts "(3,1): #{c.searchPos(3,1)}"

puts "C board \n#{c.toString}"


puts "Done with non-forking version"


puts "Now using a fork"

d= KnightsTour.new( c.board )


d.board[3][2] = 15
d.board[1][3] = 8
d.board[0][1] = 2
d.board[2][0] = 9

puts "Should have longer track"

puts "D \n#{d.toString()}"

puts "(3,1): #{d.searchPos(3,1)}"



puts "Finally, trying the maximum size"

j = -3 ; a = (1..4).map { j+= 4; (j..j+3).to_a }
e = KnightsTour.new( a )

max = 0
maxi = maxj = 0

(1..3).each { |i|
  (1..3).each { |j|
    tmp = e.searchPos(i,j)
    if tmp > max 
      puts "Setting max"
      max,maxi,maxj =  tmp,i,j
    end
  }
}

puts "Total max: #{max}, i=#{maxi}, j=#{maxj}"


v = 5
j = 1-v ; a = (1..4).map { j+= v; (j..j+v-1).to_a }

f = KnightsTour.new( a )
puts f.toString
puts "F: \n#{f.toString}"
maxi = f.searchPos(4,4)
puts "Maxi = #{maxi}"
