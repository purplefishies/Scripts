#!/usr/bin/env ruby
require 'csv'

abort "Usage: #{$0} HOUR MINUTE" unless ARGV.size == 2

hour   = ARGV[0].to_i
minute = ARGV[1].to_i

# Normalize
hour   %= 12
minute %= 60

display_hour = (hour == 0 ? 12 : hour)
time_str = format("%d:%02d", display_hour, minute)
basename = format("clock_%02d_%02d", hour, minute)

tex_file = "#{basename}.tex"
pdf_file = "#{basename}.pdf"
png_file = "#{basename}.png"
csv_file = "anki_cards.csv"

# Write LaTeX
File.open(tex_file, "w") do |f|
  f.write <<~TEX

    \\documentclass[tikz,border=2pt]{standalone}
    \\usepackage{tikz}
    \\begin{document}

\\begin{tikzpicture}[scale=2]

% Outer circle
\\draw[thick] (0,0) circle (1);

% Minute ticks (thin)
\\foreach \\m in {0,...,59} {
  \\pgfmathtruncatemacro{\\isHourTick}{mod(\\m,5)}
  \\pgfmathsetmacro{\\angle}{90 - 6*\\m}

  \\ifnum\\isHourTick=0
    % skip hour positions
  \\else
    \\draw[thin]
      ({0.96*cos(\\angle)},{0.96*sin(\\angle)}) --
      ({1.00*cos(\\angle)},{1.00*sin(\\angle)});
  \\fi
}

% Hour ticks and numbers
\\foreach \\h in {1,...,12} {
  \\pgfmathsetmacro{\\angle}{90 - 30*\\h}

  % Hour tick
  \\draw[thick]
    ({0.90*cos(\\angle)},{0.90*sin(\\angle)}) --
    ({1.00*cos(\\angle)},{1.00*sin(\\angle)});

  % Hour number
  \\node at
    ({0.75*cos(\\angle)},{0.75*sin(\\angle)}) {\\small \\h};
}

% Time variables
\\def\\hour{#{hour}}
\\def\\minute{#{minute}}

% Hand angles
\\pgfmathsetmacro{\\angMinute}{90 - 6*\\minute}
\\pgfmathsetmacro{\\angHour}{90 - (30*\\hour + 0.5*\\minute)}

% Hour hand
\\draw[thick]
  (0,0) --
  ({0.55*cos(\\angHour)},{0.55*sin(\\angHour)});

% Minute hand
\\draw[thick]
  (0,0) --
  ({0.85*cos(\\angMinute)},{0.85*sin(\\angMinute)});

% Center dot
\\fill (0,0) circle (0.02);

    \\end{tikzpicture}

    \\end{document}
  TEX
end

# Build PDF
system("pdflatex -interaction=nonstopmode #{tex_file} > /dev/null") or
  abort "pdflatex failed"

# Convert to PNG (300 DPI)
system("convert -density 300 #{pdf_file} -quality 100 #{png_file}") or
  abort "convert failed"

# Append to CSV (Anki-safe)
CSV.open(csv_file, "ab", force_quotes: true) do |csv|
  csv << [
    %Q{<img src="#{png_file}">},
    time_str
  ]
end

system("cp #{png_file} /home/jdamon/.local/share/Anki2/Jimi/collection.media" )

puts "Generated #{png_file} (#{time_str})"


