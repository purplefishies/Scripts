#!/bin/bash
if [ $# -lt 1 -o $1 == "help" ] ; 
then
   echo "Usage: $0 <user_defined|online_1mqotd|online_rand>"
   exit
else
   source=$1
fi
 
## Grab a quote from a user defined list
if [ $source == "user_defined" ]
then
 
num_quotes=10
rand=$[ ( $RANDOM % $num_quotes ) + 1 ]
 
case $rand in
   1) quote="Some things Man was never meant to know. For everything else, there's Google.";;
   2) quote="The Linux philosophy is 'Laugh in the face of danger. Oops. Wrong One. 'Do it yourself'. Yes, that's it.  -- Linus Torvalds";;
   3) quote="... one of the main causes of the fall of the Roman Empire was that, lacking zero, they had no way to indicate successful termination of their C programs. -- Robert Firth";;
   4) quote="There are 10 kinds of people in the world, those that understand trinary, those that don't, and those that confuse it with binary.";;
   5) quote="My software never has bugs. It just develops random features.";;
   6) quote="The only problem with troubleshooting is that sometimes trouble shoots back.";;
   7) quote="If you give someone a program, you will frustrate them for a day; if you teach them how to program, you will frustrate them for a lifetime.";;
   8) quote="You know you're a geek when... You try to shoo a fly away from the monitor with your cursor. That just happened to me. It was scary.";;
   9) quote="We all know Linux is great... it does infinite loops in 5 seconds. -- Linus Torvalds about the superiority of Linux on the Amterdam Linux Symposium";;
   10) quote="By golly, I'm beginning to think Linux really *is* the best thing since sliced bread.  -- Vance Petree, Virginia Power";;
esac
 
   echo "Random Quote: $quote" | fmt -80
 
## Grab and parse the "motivational quote of the day" from quotationspage.com.
# TODO: Parse the author as well.  Maybe use same method as online_rand.
elif [ $source == "online_1mqotd" ]
then
   quote=$(wget -q -O - http://www.quotationspage.com/data/1mqotd.js | grep "tqpQuote" |\
           sed "s/document.writeln(\'\<dt class=\\\\'tqpQuote\\\\'>/\"/g; s/\<\/dt\>\');/\"/g")
 
   echo "Random Quote: $quote" | fmt -80
 
## Grab and parse a random quote from quotationspage.com.
# TODO: Only print author mini-bio if it exists, as opposed to all the time.
elif [ $source == "online_rand" ]
then
   getquote(){
      num_online_quotes=9999
      rand_online=$[ ( $RANDOM % $num_online_quotes ) + 1 ]
      # In HTML source, <dt> is unique to quote and </dd> is unique to author
      # The field separators (FS) are either < or > which is [<>] in posix
      # TODO: Wanted to print as "quote -- author \n (mini-bio)", but MacOSX 'fmt' is blah
      quote=$(wget -q -O - "http://www.quotationspage.com/quote/$rand_online.html" |\
       grep -e "<dt>" -e "</dd>" | awk -F'[<>]' '{
         if($2 ~ /dt/)
         { print $3 }
         else if($4 ~ /b/)
         { print "-- " $7 "  \n(" $19 ")"}
       }')
   }
      i=1
      # 5 Attempts at obtaining a quote.  Silently fail.
      while [ $i -lt 5 ]
      do
         getquote
         echo "$quote" | grep ERROR > /dev/null
         if [ $? -eq 0 ]
         then
            getquote
            i=`expr $i + 1`
         else
            echo "Random Quote: $quote" | fmt -80
            exit
         fi
      done
fi
