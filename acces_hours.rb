#!/usr/bin/env ruby

require 'rubygems'
require 'chronic'
require 'time'
require 'date'
require 'business_time'
require 'holiday'
require 'time_diff'

lines = File.read( ARGV[0] ).split("\n")
subt  = lines.find_all { |i| i =~ /^\s*\|(\s*\-)/ }
lines = lines.find_all { |i| i !~ /^\s*(\#.*)?$/ && i !~ /(In|Out)/ && i !~ /^\s*\|(\s*\-)/ }

vals = lines.collect { |i| tmp=i.split("|").find_all { |j| j !~ /^\s*$/ }; [Chronic.parse(tmp[0]),Chronic.parse(tmp[1])] 
}

exclude_days = subt.collect { |i| i.split("|").find_all { |j| j !~ /^\s*$/ }.first }.collect { |i| i =~ /^\s*-(\d+):(\d+)/; [$1.to_i,$2.to_i] }.reduce([0,0]) { |ac,v| [ac[0]+v[0],ac[1]+v[1]] }

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
#puts "Vals: #{vals}"
#puts "Fst: #{fst}"
#puts "lst: #{lst}"
exp_hours = 0
dptr = Chronic.parse("#{fst.year}-#{fst.month}-#{fst.day} 00:00:00")  
lst = Chronic.parse("#{lst.year}-#{lst.month}-#{lst.day} 00:00:00")
#puts "dptr: #{dptr.class}"

while dptr <= lst
  if dptr.workday?
    #puts "Adding 8 hours for #{dptr}"
    exp_hours += ( dptr.workday? ? 8 : 0 )
  end
  dptr += 24.hours
end

exp_hours += exclude_days[0]


#Time.parse( sprintf("%s:%s","#{exp_hours}","0") )
#delta = ( hours.hours + mins.to_i.minutes - exp_hours.hours)
#puts "Totsum #{totsum} exp=#{totsum - exp_hours*60}"
delta = ( totsum - exp_hours * 60*60)

deltah = (delta.to_f / (60*60)).to_i
#puts "Deltah: #{deltah}"
deltam = sprintf("%2.2d", (delta % 3600 ) / 60)
#puts "deltam: #{deltam}"


puts "Total: #{hours}:#{mins} Exptd: #{exp_hours}:00 Delta: #{deltah}:#{deltam}"


