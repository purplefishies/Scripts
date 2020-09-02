#!/usr/bin/perl
while(<>) { 
    s{\\}{\\textbackslash}g;
    s{foo}{BAR}gi;
    print;
}


