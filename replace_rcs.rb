#! /usr/bin/env ruby
data = STDIN.read
last_date = `git log --pretty=format:"%ad" -1`
author  = `git log --pretty=format:"%an <%ae>" -1`
release  = `git log --pretty=format:"%h" -1`
data.gsub!('$Format: %ad$', '$Date: ' + last_date.to_s + '$')
data.gsub!('$Format: %an <%ae>$','$Author: ' + author + '$' )
data.gsub!('$Format: %t$','$Release: ' + release + '$' )
puts data

