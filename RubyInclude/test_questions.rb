#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'xml/mapping'
require 'rexml/document'
require 'open-uri'
require 'tempfile'
require 'ostruct'


# doctest: testing QAPS
# >> 1 + 0
# => 1
# >> file = File.open("/tmp/foo","w")
# >> file.write("\\begin{KQAP}\n\\begin{KQ}Foo\n\\end{KQ}\n\\begin{KA}Bar\n\\end{KA}\n\\end{KQAP}\n")
# >> file.close
# >> file.path
# >> res = FIND_QAPS.call( file.path )
# >> res[0].question 
# => "Foo"
# >> res[0].answer
# => "Bar"
FIND_QAPS = Proc.new { |file|
  # puts "Using QAPS"
  if RUBY_VERSION == "1.8.7" 
    fp = IO.popen("between.pl -s 'begin\{[Kk]?QAP\d?\}' -e 'end\{[kK]?QAP\d?}' -m -i -f #{file}")
  else
    fp = IO.popen("between.pl -s 'begin\{[Kk]?QAP\d?\}' -e 'end\{[kK]?QAP\d?}' -m -i -f #{file}", :external_encoding=>"UTF-8")
  end
  
  lines = fp.readlines()
  
  defined? debugger ? debugger : nil 
  begin
    problems =  lines.join("").split(/\s+(?=\\begin\{[kK]?QAP\d?\})/).collect { |i|
      Problem.load_qaps( i )
    }
  rescue Exception => e
    STDERR.puts("Had a problem : #{e}")
  end
  problems;
}

# doctest: Find summaries in Tex files
# >> 1 + 0
# => 1
FIND_SUMMARIES = Proc.new { |file|
  entries = %w{sectionsummary subsectionsummary subsubsectionsummary paragraphsummary subparagraphsummary}
  problems = []
  re = Regexp.new("\(" + entries.join("|") + "\)" )
  fp = File.open(file)
  stack = [fp.pos]
  while line = fp.gets
    stack.push(fp.pos)
    if line =~ re 
      matched = $1
      matched.sub!(/summary/,'' )
      oldre = Regexp.new("\\\\" + matched + "\\*?\{" )
      for i in (0..(stack.length-2))
        fp.seek(stack[(0..(stack.length-2)).to_a.reverse[i]], IO::SEEK_SET  )
        line = fp.gets
        if line !~ oldre
          next
        else
          # Join the lines 
          fp.seek(stack[(0..(stack.length-2)).to_a.reverse[i]], IO::SEEK_SET  )
          data = fp.read(stack.reverse[1] - stack.reverse[i+1])
          data =~ Regexp.new("\\\\"+ matched + "\\*?\{(.*?)\}" , Regexp::MULTILINE)
          question = $1
          # Go and find the first element again
          fp.seek(stack[(0..(stack.length-2)).to_a.reverse[0]], IO::SEEK_SET  )
          line = fp.getc
          while line !~ re
            line += fp.getc
          end
          nxt = fp.getc
          while nxt != "{"
            line += nxt
            nxt = fp.getc
          end
          line += nxt
          count=1
          while count != 0
            line += fp.getc
            if line[line.length-1] == "}"
              count -= 1
            elsif line[line.length-1] == "{"
              count += 1
            else
            end
          end
          line =~ Regexp.new("\\\\"+ matched + "summary" + "\\*?\{(.*?)\}" , Regexp::MULTILINE)
          answer = $1
          problems.push( Problem.new(question,answer) )
          break
        end
      end
    end
  end
  problems
}

# doctest: ProblemGenerator
# >> file = File.open("/tmp/foo","w")
# >> file.write("\\begin{KQAP}\n\\begin{KQ}Foo\n\\end{KQ}\n\\begin{KA}Bar\n\\end{KA}\n\\end{KQAP}\n")
# >> file.close
# >> file.path
# >> pg = ProblemGenerator.new().generate_for_file("/tmp/foo")
# >> pg[0].question
# >> "Foo"
class ProblemGenerator
  attr_reader :finders
  def initialize(finders=[FIND_QAPS,FIND_SUMMARIES])
    @finders = finders
  end
  def generate_for_file(*files)
    probs = []
    for file in files
      for i in @finders 
        probs += i.call( file )
      end
    end
    probs
  end
end

# doctest: Adding a question
# >> a = Problem.load_qaps( "\\begin{KQ}Foo\\end{KQ}\n\\begin{KA}Bar\\end{KA}\n" )
# >> a.question
# => "Foo"
# >> a.answer
# => "Bar"
class Problem
  attr_accessor :question, :answer

  def initialize(question="",answer="")
    @question = question
    @answer   = answer
  end

  def self.load_qaps(problem)
    tmp = Problem.new("")
    tmp.question = tmp._load_question( problem )
    tmp.answer = tmp._load_answer( problem )
    tmp
  end

  def to_s
    "[@question=#{@question} , @answer=#{@answer}]"
  end

  def setQuestion(q)
    @question = q
  end
  def setAnswer(a)
    @answer = a
  end

  def normalize(str)
    REXML::Text::normalize(str)    
  end

  def _load_question(problem)
    problem =~ /^.*(?:\\begin\{[kK]?Q\d?\}\s*(\S.*?)\s*\\end\{[kK]?Q\d?\}).*$/xmsu
    tmp = $1
    if !tmp.nil?
      tmp.gsub!(/\n/," ")
    else
      tmp = ""
    end
    self.normalize( tmp )
  end

  def _load_answer(problem)
    problem =~ /^.*(?:\\begin\{[kK]?A\d?\}\s*(\S.*?)\s*\\end\{[kK]?A\d?\}).*$/xmsu
    tmp =  $1
    self.normalize(tmp)
  end
end

class ProblemsQuiz
  def initialize(options={},*problems)
    problems.flatten!
    @problems = problems
    @options = options
  end

  #
  #
  def get_choice
    foundchoice = false
    while !foundchoice
      line = STDIN.gets

      if line.nil?
        # puts "value reched\n"
        foundchoice = true
        line = "Y"
      else
        line.chomp!
        if line =~ /^\s*$/
          foundchoice = true
          line = "Y"
        else
          foundchoice = true
        end
      end
    end
    line
  end

  def show_score
    puts "Correct: #{@stats.results.find_all{|i| i == "y"}.length}, Wrong: #{@stats.results.find_all{|i|i != "y"}.length}"
  end

  def show_menu
    keepshowing = true
    menu= "  Choices:
    1:       Show score
    2:       Save score
    3:       Exit
    4:       Undo last score
    Default: Return to game
"
    while keepshowing
      puts menu
      line = STDIN.gets
      line.chomp!
      if line == "1"
        show_score
      elsif line == "2"
        puts "Saving score"
      elsif line == "3"
        exit(0)
      elsif line == "4"
        line = "undo"
        keepshowing = false
      elsif line == "?"
      else
        keepshowing = false
        line = "reshow"
      end
    end
    line
  end

  def query_choice(line,q)
    puts "Question: #{q.question}"

    while line == "?"
      line = get_choice
      if line == "?"
        res = show_menu
        if res == "reshow"
          puts "Question: #{q.question}"
        elsif res == "undo"
          begin
            q = @stats.questions.pop
            q.question
          rescue Exception => e
            q = @workingset.sample(1)[0]
          end
          @stats.results.pop
          puts "Question: #{q.question}"
        end
      end
    end
  end

  def run
    @workingset = @problems
    endloop = false
    @stats = OpenStruct.new
    @stats.successes = 0
    @stats.failures = 0
    @stats.questions = []
    @stats.results = []

    until endloop 
      q = @workingset.sample(1)[0]
      @stats.questions.push( q )
      line = "?"

      while line == "?"
        query_choice(line,q)
        
        puts "Answer: #{q.answer}"
        print "Correct [Y/n/?] "
        line = get_choice
        if line.nil?
          break
        end
      end

      if line =~ /(y|ye|yes)/i
        @stats.results.push("y")
        @stats.successes += 1
      else
        @stats.results.push("n")
        @stats.failures += 1
      end
    end
    puts "Successes:#{@stats.successes}"
    puts "Failures :#{@stats.failures}"
  end
end


class LatexProblems
  attr_reader :problems , :collections, :collection_range
  attr_reader :base_type
  def initialize(args)
    if args[:basetype] 
      @base_type = args[:basetype] 
    else
      @base_type = Problem
    end
    if args[:file]  && File.file?(args[:file])
      loadFile( args[:file] )
    end
  end
  def to_s()
    retstring += @problems.collect { |i| 
      i.to_s
    }
    return retstring
  end

  def self.findLatexPackages(file) 
    packages = File.read(file).split("\n").find_all { |i| i =~ /^\s*((\\usepackage|\\input).*)/ } 
    renews   = File.read(file).split("\n").find_all { |i| i =~ /^\s*(\\renewcommand.*)/ } 
    packages |= renews
    packages
  end

  def loadFile(file)
    defined? debugger ? debugger : nil 
    @problems = _findProblems(file )
    puts "Found problems #{problems.length}"
    @collections = [file.gsub(/\.tex/,'')]
    @collection_range = [[0,@problems.length-1]]
  end

  def addProblems(file2)
    newproblems = _findProblems( file2 )
    @collections.push( file2.gsub!(/\.tex/,''))
    @collection_range += [@problems.length, newproblems.length-1]
    @problems = @problems + newproblems
  end

  def _findProblems(file)
    if RUBY_VERSION == "1.8.7" 
      fp = IO.popen("between.pl -s 'begin\{[Kk]?QAP\d?\}' -e 'end\{[kK]?QAP\d?}' -m -i -f #{file}")
    else
      fp = IO.popen("between.pl -s 'begin\{[Kk]?QAP\d?\}' -e 'end\{[kK]?QAP\d?}' -m -i -f #{file}", :external_encoding=>"UTF-8")
    end

    lines = fp.readlines()

    defined? debugger ? debugger : nil 
    begin
      problems =  lines.join("").split(/\s+(?=\\begin\{[kK]?QAP\d?\})/).collect { |i|
        @base_type.new( i )
      }
    rescue Exception => e
      STDERR.puts("Had a problem : #{e}")
    end
    return problems;
  end

end

