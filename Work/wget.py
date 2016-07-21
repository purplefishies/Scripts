#!/usr/bin/env python

import sys  
from PyQt4.QtGui import *  
from PyQt4.QtCore import *  
from PyQt4.QtWebKit import *  
from lxml import html 

class Render(QWebPage):  
  def __init__(self, url):  
    self.app = QApplication(sys.argv)  
    QWebPage.__init__(self)  
    self.loadFinished.connect(self._loadFinished)  
    self.mainFrame().load(QUrl(url))  
    self.app.exec_()  
  
  def _loadFinished(self, result):  
    self.frame = self.mainFrame()  
    self.app.quit() 


if __name__ == "__main__":
    #url = 'http://pycoders.com/archive/'  
    #This does the magic.Loads everything
    url = sys.argv[1]
    #print "%s" % ( url )
    #print "%d" % ( len(sys.argv))
    #sys.exit(1)
    r = Render(url)  
    #result is a QString.
    result = r.frame.toHtml()
    formatted_result = str(result.toAscii())
    fp = file("index.html","w")
    fp.write(formatted_result)
    print formatted_result
    #tree = html.fromstring(formatted_result)
    #archive_links = tree.xpath('//div[@class="campaign"]/a/@href')
    #print archive_links
