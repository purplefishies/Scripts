#!/usr/bin/env perl

use 5.010;

# set fg: \e[38;2;R;G;Bm
# set bg: \e[48;2;R;G;Bm

$s = join "", map {"\e[38;2;230;".(30 + $i++).";147;48;2;0;0;".($i). "m$_"}
    split //, "Konsole and Konsole-based Yakuake support 24-bit colors, yaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaay...";
say $s, "\e[0m";


