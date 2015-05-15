#!/usr/bin/env ruby

require 'rubygems'
require 'chronic'
require 'time'
require 'date'
require 'business_time'
require 'holiday'


lines = File.read( ARGV[0] ).split("\n")
lines = lines.find_all { |i| i !~ /^\s*(\#.*)?$/ && i !~ /(In|Out)/ }
vals = lines.collect { |i| tmp=i.split("|").find_all { |j| j !~ /^\s*$/ }; [Chronic.parse(tmp[0]),Chronic.parse(tmp[1])] }

sumdays = Hash.new { |h,k| h[k] = { :sum => 0 , :date => nil } }

def uniquafy(day)
  day.to_date.to_s
end

vals.each { |i|
  if( i[0].mday != i[1].mday )
    sumdays[uniquafy( i[0] )][:sum] += ( (i[0] + 1.day).beginning_of_day - i[0] ).abs
    if sumdays[uniquafy( i[0] )][:date].nil?
      sumdays[uniquafy( i[0] )][:date] = i[0].to_date
    end
    sumdays[uniquafy( i[1] )][:sum] += ( (i[1] - (i[0]+1.day).beginning_of_day ) ).abs
    if sumdays[uniquafy( i[1] )][:date].nil?
      sumdays[uniquafy( i[1] )][:date] = i[1].to_date
    end
  else                    
    sumdays[uniquafy( i[0] )][:sum] += (i[0]-i[1]).abs
    sumdays[uniquafy( i[0] )][:date] = i[0].to_date
  end
}

totsum = 0
# vals.collect { |i| i[0].day }.uniq.each { |day| 
#vals.collect { |i| uniquafy( i[0] ) } { |day| 

vals.collect {|i| [uniquafy( i[0] ),uniquafy( i[1] )] }.flatten.uniq.each  { |day| 

  # Custom subtraction script
  sumdays[day][:sum] = ( sumdays[day][:sum] > 3600*6 ? (sumdays[day][:sum] - 30*60) : sumdays[day][:sum] )

  totsum += sumdays[day][:sum]
  hours = (sumdays[day][:sum] / 3600).to_i
  begin
    mins  = ((sumdays[day][:sum] % 3600 )/60).round
    puts "#{sumdays[day][:date].strftime("%a %b %d")}\t#{sprintf("%2d:%2.2d",hours,mins)}" 
  rescue Exception => e 
    puts "E#{e} #{sumdays[day][:date]}  hours=#{hours} mins=#{mins}"
  end

  # put.abs.to_i/3600}:#{ sprintf("%2.2d",((i[0]-i[1]).abs.to_i % 3600)/60)}
}

hours = (totsum / 3600).to_i
mins  = sprintf("%2.2d",((totsum % 3600 )/60).round)
fst = vals.sort { |a,b| a[0] <=> b[0] }.first[0]
lst = vals.sort { |a,b| a[0] <=> b[0] }.last[0]
# puts "#{vals}"
# puts "#{fst}"
exp_hours = 0
dptr = fst
while dptr <= lst
  exp_hours += ( dptr.workday? ? 8 : 0 )
  dptr += 24.hours
end


puts "Total: #{hours}:#{mins}"  
puts "Exptd: #{exp_hours}:00"


