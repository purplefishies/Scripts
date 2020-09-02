#!/usr/bin/python
import os
import sys
import re

class Process():
    def __init__(self,**kwargs):
        self.process     = kwargs["process"]
        self.application = kwargs["application"]
    def __str__(self):
        return "Process: " + str(self.process)
    def stop_process(self):
        processes = os.popen("ps -ef" ).readlines()
        found = [x for x in processes if re.match(r'^.*\s+%s' %(self.process),x,re.I) ]
        
    def start_process(self):
        ecode = os.system("open " + self.application)
        if ecode != 0:
            raise Exception("Process start error") 
    def is_alive(self):
        processes = os.popen("ps -ef").readlines()
        alive = [x for x in processes if re.search(r'%s' %(self.process),x, re.I ) ]
        ifconfig  = os.popen("ifconfig").readlines()
        ppp = [ x for x in ifconfig if re.match(r'^.*ppp', x, re.I ) ]
        len(alive) > 0 and len(ppp) > 0

if __name__ == "__main__":
    c = Process( process="Anonymizer Universal",
                 application="/Applications/Anonymizer\ Universal.app"
                 )
    c.start_process()
    print "Alive status:%s\n" % (c.is_alive() )
    c.stop_process()
    print "Alive status:%s\n" % ( c.is_alive() )


    
