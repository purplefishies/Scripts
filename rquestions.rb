#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path(ENV["HOME"] + "/Scripts/RubyInclude" ))

require 'test_questions'


#ruby -I$HOME/Scripts/RubyInclude -r 'test_questions' -e '

puts ProblemGenerator.new().generate_for_file(*ARGV).sample(1).map{ |i| "Q:\n#{i.question}\n\nA:\n#{i.answer}" }
