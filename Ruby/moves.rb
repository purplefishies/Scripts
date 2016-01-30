#!/usr/bin/ruby

require 'colorize'
OUTPUT_DIRECTORY="foo"

#gamemoves = File.read("game2.pgn").split("\n").join("") 
#fp = File.open(file,"w")

# Simple class that translates a FEN into 
# a board position
#
#
# r1b2rk1/1pq4p/p2p2p1/2NPpp1n/2P1P3/B1N1bP2/P1Q1B1PP/1R3R1K b - - 0 19
class FEN
  #
  #
  #
  attr_accessor :lookup
  def initialize(fen)
    @pos,@to_move,@castle , @ep, @draw_number, @move_number  = fen.split(" ")
    @padding = 1
    @lookup = {
      'r' => "\342\231\234",
      'n' => "\342\231\236",
      'b' => "\342\231\235",
      'q' => "\342\231\233",
      'k' => "\342\231\232",
      'p' => "\342\231\237",
      'P' => "\342\231\231",
      'R' => "\342\231\226",
      'N' => "\342\231\230",
      'B' => "\342\231\227",
      'Q' => "\342\231\225",
      'K' => "\342\231\224"
    }
  end

  def to_bytes
    puts "Not implmented yet"
  end
  def _padding
    " "*@padding
  end
  
  def _toggle(a)
    if a =~ /[A-Z]/ 
      a.downcase
    else
      a.upcase
    end
  end

  def _lu(c,val)
    if @lookup.has_key?(val) 
      if (c % 2 == 0 ) 
        @lookup[val]
      else
        @lookup[_toggle(val)]
      end
    else 
      val
    end
  end

  def _cb(c,val)
    # bg = colorize( :color => :black,  :background => :white )
    bg = (c % 2 == 0  ? lambda { |a| a.colorize( :color => :black,  :background => :white ) } : lambda { |a| a.colorize(:color => :white, :background => :black ) } )
    #end
    bg.call( val )
  end

  def inspect 
    return [@pos.colorize(:color => :green ),@to_move.colorize( :color => :red ),@castle, @ep.colorize( :color => :green ), @draw_number, @move_number ].join(" ")
    #"Castle: #{@castle}"
    # [@pos.colorize(:color => :green ),@to_move.colorize( :color => :red ), @castle ].join(" ")
  end

  def foo
    return [@pos.colorize(:color => :green ),@to_move.colorize( :color => :red ),@castle, @ep.colorize( :color => :green ), @draw_number, @move_number ].join(" ")
  end

  def to_s
    color = 0
    return @pos.split("/").collect { |i| i.gsub(/\d/) { |m| " "*m.to_i }  }.collect { |i| tmp =i.split(//).collect { |j| color +=1 ; _cb(color,_padding + _lu(color, j ) + _padding ) }.join("") ; color += 1; tmp    } .join("\n")
  end
end


class PGN
  attr_reader :header, :game
  def initialize(header,game)
    @header = header
    @game = game
  end
end

class PGNCollection
  def self.read_file( file )
    games = []
    fp = File.open(file) 
    mode = :NOTHING
    moves = ""
    header = ""
    while !fp.eof? 
      line = fp.readline 
      if mode == :NOTHING && line.match( /^\[.*\]/) || mode == :HEADER && line.match( /^\[.*\]/)
        mode = :HEADER
        header += line.chomp
        puts "1"
      elsif mode == :HEADER && line.match(/^\s*$/ )
        mode = :IBT
        puts "2"
      elsif mode == :IBT && line.match(/^\s*1./)
        mode = :GAME
        moves += line.chomp
        puts "3"
      elsif mode == :GAME && line.match( /\d+/ )
        moves += line.chomp
      elsif mode == :GAME && line.match( /^\s*$/ )
        mode = :NOTHING
        games.push( PGN.new( header, moves ) )
        header = ""
        moves = ""
      end
    end
    fp.close()
    games
  end
end


class PGNQuiz
  attr_reader :engine , :file

  def initialize(args)
    
  end

  def self.load_file( file )
    @fp = File.open( file )
    
  end

  def process_moves( gamemoves )

    moves = gamemoves.split(/Stockfish\s*020114\s*64\s*SSE4.2: /)
    tt = moves[1..moves.length].collect { |i| j = i.sub(/^([\+-]\d+\.\d+)\s+.*$/xsm,'\1' ); j.to_f }
    
    positions = (0..tt.length-2).find_all { |i|  ((tt[i]-tt[i+1]).abs > 1.0 && (tt[i-1] - tt[i]).abs < 3 ) }
    
    positions.each { |i| 
      correct_move = moves[i+3].gsub(/\{.*?\}/sm,'').gsub(/ \d+\.\.\./,'' ).sub(/^.*\((.*?)\{.*$/,'\1' )
      # fen_position = moves[i].gsub(/^.*?\{([^}]+?)\s*\}.*$/ms,'\1' )
      fen_position = moves[i+2].gsub(/^.*?\{[^\}]+\}.*?\{([^\}]+?)\s+\}.*/ms,'\1' )
      write_quiz_file( fp,  "file.tex", fen_position, correct_move, true )
    }
  end

  
  #
  #
  #
  def write_quiz_file(file,position,moves, white_to_move )
    fp.write <<HEADER
\\documentclass{article}
\\usepackage{skak}
\\input{header}

\\begin{document}

HEADER
    fp.puts("\\begin{QAP}")
    fp.puts("\\begin{Q}")
    fp.puts("\\fenboard{" + position + "}")
    fp.puts("\\begin{figure}")
    fp.puts("\\centering")
    fp.puts( ( white_to_move ? "$$\\showboard$$" : "$$\\showinverseboard$$" ))
    fp.puts( "\\caption " + ( white_to_move ? "Fischer  Tal after" : "foo" ))
    fp.puts( "\\end{figure}" )
    fp.puts("\\end{Q}")
    fp.puts("\\begin{A}")
    fp.puts( moves )
    fp.puts("\\end{A}")

    fp.puts("\\end{QAP}")

    fp.write <<FOOTER
\\end{document}
FOOTER
    fp.close()
end


end




