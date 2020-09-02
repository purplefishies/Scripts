#!/bin/bash

# echo -ne  "Args: $#\n"
if [[ $# -lt 1 ]] ; then
    echo "Usage: $0 FEN [TIME] [NUM_GAMES]"
    exit
fi

if [[ -z $STOCKFISH ]] ; then
    STOCKFISH=$(which stockfish)
fi


tmpfile=$(mktemp --tmpdir tmp.XXXX)
if [[ -f $1 ]]; then
    # echo "FIle"
    format="epd"
    cp $1 $tmpfile
else
    # echo "Position"
    format="pgn"
    echo -ne "[FEN \"$1\"]\n[Result \"1/2-1/2\"]\n\n1/2-1/2\n" > $tmpfile 
fi

if [[ -z $2 ]] ; then
    tc="0:10"
else
    tc=$2
fi

if [[ -z $3 ]] ; then
    numgames=5
else
    numgames=$3
fi


cutechess-cli -repeat -rounds $numgames -tournament gauntlet -pgnout game.pgn -resign movecount=3 score=1600 -draw movenumber=34 movecount=8 score=20 -concurrency 3 -openings file=$tmpfile format=${format} order=random plies=16  -engine name=SFone cmd=${STOCKFISH} option.Hash=128 option.Hash=128 -engine name=SFtwo cmd=${STOCKFISH} option.Hash=128 option.Hash=128  -each proto=uci tc=$tc option.Threads=1


rm $tmpfile


#/media/jdamon/Development/Downloads/fishtest/worker/testing/cutechess-cli -repeat -rounds 317 -tournament gauntlet -pgnout game.pgn -resign movecount=3 score=400 -draw movenumber=34 movecount=8 score=20 -concurrency 3 -openings file=$tmpfile format=pgn order=random plies=16 -both name=SF cmd=/home/jdamon/Downloads/stockfish_15100720_x64_bmi2 option.Hash=128 option.Hash=128 -each proto=uci tc=14.89+0.05 option.Threads=1

#cutechess-cli -debug  -repeat -games 5 -rounds 1 -tournament gauntlet  -draw movenumber=34 movecount=8 score=20  -engine name=SFWhite cmd="/home/jdamon/Downloads/stockfish_15100720_x64_bmi2" proto=xboard  -engine name=SFBlack cmd="/home/jdamon/Downloads/stockfish_15100720_x64_bmi2"  proto=uci -each option.OwnBook=false option.Hash=128 restart=on timemargin=50 tc=555/1:0+0  -pgnout ./game.pgn
