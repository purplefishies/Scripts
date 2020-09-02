#!/usr/bin/env ruby
#
#

require 'rubygems'
require 'optparse'
require 'ostruct'

# Greate resources
# http://tex.stackexchange.com/questions/105589/insert-pdf-file-in-latex-document
# http://tex.stackexchange.com/questions/57746/includepdf-as-a-figure
# https://www.sharelatex.com/learn/Sections_and_chapters


LEVELS = %w{part section subsection subsubsection paragraph subparagraph}

def parse(argv)
  options         = OpenStruct.new
  options.subject = "Test result"
  options.sguser  = ENV['SENDGRID_USERNAME']
  options.sgpass  = ENV['SENDGRID_PASSWORD']

  optparse = OptionParser.new {  |opts|   
    # Set a banner, displayed at the top   # of the help screen.   
    opts.banner = "Usage: #{$0} [options]" 
    opts.separator ""
    opts.separator "Specific options:"
    
  }
  begin
    optparse.parse!( argv )
  rescue OptionParser::ParserError => e 
    STDERR.puts e.message,"\n", op
    exit(-1)
  end
  options
end




#
#
#
def generate_pdf
  
  fp = File.open("top.tex","w")
  level = 0
  output =  process_directory(".", level, "" )
  fp.puts get_header()
  fp.puts output
  fp.puts ""
  fp.puts get_footer()
  fp.close()

  pdflatex( fp.path )

end

#
#
#
def pdflatex(file)
end

#
#
def nicify_entry(entry)
  
  return entry.gsub(/^\d+_(.*)$/,'\1').gsub(/\.pdf$/,'')
end

def make_label(entry,path)
  if path == "" 
    return "sec:#{entry.gsub(/^\d+_(.*)$/,'\1').gsub(/\.pdf$/,'')}"    
  else
    return "sec:#{path.split("/").find_all { |i| i != "" }.join("-")}-#{entry.gsub(/^\d+_(.*)$/,'\1').gsub(/\.pdf$/,'')}"    
  end

end

#
#
#
def process_directory(dir, level, path,order=nil)
  retstr = ""
  dirs = Dir.entries(".").find_all { |i| File.directory?(i) && i !~ /^\.{1,2}$/ && i =~ /^[A-z]/ }
  files = Dir.entries(".").find_all { |i| File.file?(i) && i =~ /^\S+\.pdf/ && i !~ /(tmp|top)\.pdf/ } 
  combined = (files + dirs).sort
  
  combined.each { |entry|
    if File.directory?(entry)
      if level < LEVELS.length-1 
        # cd to entry"
        curdir = Dir.pwd
        Dir.chdir(entry)
        retstr += "\n\n\\#{LEVELS[level]}{#{entry}}\\label{#{make_label(entry,path)}}\n\n"
        retstr += process_directory(entry, level + 1, "#{path}/#{entry}", order )
        Dir.chdir(curdir)
        # cd out of entry
      else
        STDERR.puts("Too deep, can't descend into #{entry}")
        # Don't append to retstr
      end
    else                        # File processing here

      retstr += "\\includepdf[pages=-,scale=0.9,pagecommand={\\#{LEVELS[level]}{#{nicify_entry(entry)}}\\label{#{make_label(entry,path)}}}]{#{Dir.pwd}/#{entry}}\n\n"

    end
  }
  return retstr
end


def get_header
%q{
\ifdefined\MASTERDOCUMENT
\else
\documentclass{article}
\input{header}
\usepackage[final]{pdfpages}
\setboolean{@twoside}{false}

\begin{document}
\fi
}
end

def get_footer
%q{
\ifdefined\MASTERDOCUMENT
\endinput
\else
\expandafter\enddocument
\fi
}
end


#
# Main code here
#
 
if __FILE__ == $PROGRAM_NAME

  opts = parse(ARGV)
  generate_pdf()
end

