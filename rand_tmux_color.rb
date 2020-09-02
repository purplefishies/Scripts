#!/usr/bin/env ruby


print `tmux_colors.sh`.split("\n").map { |i| i.gsub(/\e\[(\d+);\d+;\d+m/, '') }.sample
