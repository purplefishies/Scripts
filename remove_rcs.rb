#! /usr/bin/env ruby
data = STDIN.read
data.gsub!(/\$Date:.*?$/,'$Format: %ad$')
data.gsub!(/\$Author:.*?$/,'$Format: %an <%ae>$' )
data.gsub!(/\$Release:.*?$/,'$Format: %t$' )
puts data

