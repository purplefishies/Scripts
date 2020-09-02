#!/usr/bin/ruby 

$LOAD_PATH.unshift( File.expand_path( ENV["HOME"] + "/Scripts/RubyInclude" ))

require 'test_questions'



ProblemsQuiz.new({},ProblemGenerator.new().generate_for_file(*ARGV)).run
