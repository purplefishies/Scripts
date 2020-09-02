#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'


# Simple script that will remap file
# locations
#

class WriteFile < File
end

def find_files(dirs=[],type="*.java")
  files = []
  dirs.each  { |d|
    if d.class == Dir
      files.push(*`find #{d.path} -name "#{type}"`.split("\n"))
    else
      files.push(*`find #{d} -name "#{type}"`.split("\n") )
    end
  }
  files
end

def find_mappings(file)
  fp = File.open(file )
  cur_package = nil
  allclasses = {}
  begin 
    while ( line = fp.readline() )
      if line =~ /^\s*package\s+([A-z\d\.]+)\s*?[;]?\s*$/
        cur_package = $1
        cur_package.gsub!("\.","::")
      elsif line =~ /^\s*(?:(?:(?:public|final|static)\s*)*)class\s+([A-z\d]+).*$/
        cur_class = $1
        allclasses["#{cur_package}::#{cur_class}"] = file
      end
    end
  rescue EOFError => e 
  ensure 
    fp.close
  end
  allclasses
end

def parse_options(args=[])
  options         = OpenStruct.new
  options.subject = "Test result"
  options.filters = []
  options.directories = []
  options.type = nil
  options.filter = nil

  optparse = OptionParser.new {  |opts|   
    # Set a banner, displayed at the top   # of the help screen.   

    OptionParser.accept(WriteFile, /^(.*)$/) do |f|
      tmp = File.open(f,"w")
      tmp
    end

    OptionParser.accept(Regexp, /^(.*)$/ ) do |r|
      Regexp.new(r)
    end

    OptionParser.accept(Dir, /^(.*)$/ ) do |d|
      if !d.nil? && File.directory?(d)
        Dir.new(d)
      else
        nil
      end
    end
   
    opts.banner = "Usage: #{$0} [options]" 
    opts.separator ""
    opts.separator "Specific options:"
    
    opts.on("-d","--directory DIRECTORY", String, "Directories to search for java / scala files" ) { |dir|
      if File.directory?(dir)
        options.directories << Dir.new(dir)
      end
    }
    opts.on(nil,"--java", "Search for Java" ) { |reg|
      options.type = "*.java"
    }
    opts.on(nil,"--scala", "Search for Scala" ) { |reg|
      options.type = "*.scala"
    }
    opts.on("-c","--class", "Just show full classes" ) { |t|
      options.filter = lambda { |x| x[0].gsub("::",".")}
    }

    opts.separator ""
    opts.separator "Common options:"

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
    end
  }

  begin
    optparse.parse!( args )
  rescue Exception => e 
    STDERR.puts e.message,"\n"
    exit(-1)
  end

  # if options.out.nil?
  #   options.out = File.open(options.outfile,"w")
  # end
  if options.type.nil?
    options.type = "java"
  end
  options
end

#
# Main code here
#
if __FILE__ == $PROGRAM_NAME

  opts = parse_options(ARGV)
  # puts "opts: #{opts}"
  files = find_files( opts.directories, opts.type )
  # puts "#{files}"
  lookups = {}
  files.each { |i|
    lookups.merge! find_mappings( i )
  }
  #puts "Lookups #{lookups}"
  if !opts.filter.nil? && opts.filter.class == Proc
    puts lookups.map {|x| opts.filter.call(x) }
  else
    lookups.keys.each { |key|
      puts "bin/classes/#{key.gsub("::","/")}.class:#{lookups[key]}"
    }
  end

end

