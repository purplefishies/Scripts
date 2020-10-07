#!/usr/bin/ruby


def colorize(s, color_code)
  "\e[#{color_code}m#{s}\e[0m"
end


def red(s)
  colorize s, 31
end


def green(s)
  colorize s, 32
end


while gets
  $_.gsub!(/(  PASSED)/,green('\1'))
  $_.gsub!(/(  FAILED)/,red('\1'))
  $_.gsub!(/(  ERROR)/,red('\1'))
  $_.gsub!(/\d+ FAILED.*/) { |s| red s }
  puts $_
end

