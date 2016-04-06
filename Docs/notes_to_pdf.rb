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

class WriteFile < File
end

def parse(argv)
  options         = OpenStruct.new
  options.subject = "Test result"
  options.filters = []
  options.dirfilters = []
  options.outfile = "top.tex"
  options.out = nil

  optparse = OptionParser.new {  |opts|   
    # Set a banner, displayed at the top   # of the help screen.   

    OptionParser.accept(WriteFile, /^(.*)$/) do |f|
       # if !File.file?( f )
       #   puts "Issue"
       #   raise "#{f} is not a valid File"
       # else
       #   puts "opening file"
      tmp = File.open(f,"w")
      tmp
    end

    OptionParser.accept(Regexp, /^(.*)$/ ) do |r|
      Regexp.new(r)
    end
   

    opts.banner = "Usage: #{$0} [options]" 
    opts.separator ""
    opts.separator "Specific options:"
    
    opts.on("-o", "--output OUTFILE", WriteFile, "Output file (default top.tex)" ) { |file|
      options.out = file
    }

    opts.on("-f", "--filter1 FILTER [--filter FILTER ]", Regexp, "Regex for pruning" ) { |reg|
      options.filters << reg
    }
    opts.on("-d", "--dirfilter FILTER [--dirfilter FILTER ]", Regexp, "Regex for directory pruning" ) { |reg|
      options.dirfilters << reg
    }


    opts.separator ""
    opts.separator "Common options:"

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
    end
  }

  begin
    optparse.parse!( argv )
  rescue OptionParser::ParserError => e 
    STDERR.puts e.message,"\n", op
    exit(-1)
  end

  # puts "Filters #{options.filters}"
  if options.out.nil?
    options.out = File.open(options.outfile,"w")
  end
  options
end




#
#
#
def generate_pdf(opts)
  
  # fp = File.open(opts.outfile.path,"w")
  level = 0
  output =  process_directory(opts, ".", level, "" )
  opts.out.puts get_header()
  opts.out.puts output
  opts.out.puts ""
  opts.out.puts get_footer()
  opts.out.close()

  pdflatex( opts.out.path )

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

def make_entry(entry,path)
  if path == "" 
    return "sec:#{entry.gsub(/^\d+_(.*)$/,'\1').gsub(/\.pdf$/,'')}"    
  else
    return "sec:#{path.split("/").find_all { |i| i != "" }.join("-")}-#{entry.gsub(/^\d+_(.*)$/,'\1').gsub(/\.pdf$/,'')}"    
  end

end

def make_directory_entry(entry)
  return entry.gsub(/^\d+_(.*)/,'\1').gsub(/_/,' ').gsub(/comma/,',')
end




#
#
#
def process_directory(opts,dir, level, path,order=nil)
  retstr = ""
  dirs = Dir.entries(".").find_all { |i| File.directory?(i) && i !~ /^\.{1,2}$/ && i =~ /^[A-z\d]/ }.find_all { |dir|
    opts.dirfilters.inject(true) { |res,filt|  res &= !filt.match(dir) }
  }

  files = Dir.entries(".").find_all { |i| 
    if File.file?(i) && i =~ /^\S+\.pdf/ && i !~ /(tmp|top)\.pdf/ 
      if ( opts.filters.length > 0 )  
        ret = true
        opts.filters.each { |filt|
          # puts "BLAH!!!\n\n"
          if i =~ filt
            # puts "FOO\n\n"
            ret = false
            break
          end
        }
        ret
      else 
        true
      end
    else
      false
    end
  } 
  combined = (files + dirs).sort
  
  combined.each { |entry|
    if File.directory?(entry)
      if level < LEVELS.length-1 
        # cd to entry"
        curdir = Dir.pwd
        Dir.chdir(entry)
        retstr += "\n\n\\#{LEVELS[level]}{#{make_directory_entry(entry)}}\\label{#{make_label(entry,path)}}\n\n"
        retstr += process_directory(opts,entry, level + 1, "#{path}/#{entry}", order )
        Dir.chdir(curdir)
        # cd out of entry
      else
        STDERR.puts("Too deep, can't descend into #{entry}")
        # Don't append to retstr
      end
    else                        # File processing here

      retstr += "\\includepdf[pages=-,scale=0.9,pagecommand={\\#{LEVELS[level]}{\\themycounter}\\label{#{make_label(entry,path)}}\\stepcounter{mycounter}}]{#{Dir.pwd}/#{entry}}\n\n"

      retstr += "\\setcounter{mycounter}{1}\n\n"

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
\setcounter{secnumdepth}{-2}
\newcounter{mycounter}
\setcounter{mycounter}{1}

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
  generate_pdf(opts)
end

