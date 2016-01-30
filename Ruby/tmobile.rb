#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'mechanize'

agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
agent.ssl_version = :TLSv1


parameters = {}
parameters["Login1:txtMSISDN"] = "4084290929"
parameters["Login1:txtPassword"] = password
parameters["Login1:hdnIsMobileServiceAvailable"] = "True"
parameters["Login1:hdnIsBotDetectCaptchaAvailable"] = false
parameters["Login1:hdnIsBotCaptchaWeakPwd"] = false
parameters["Login1:customerTypeField"] = "POSTPAID"
parameters["__EVENTTARGET"] = "Login1$btnLogin"
parameters["Login1:chkRemember"] = "on"

url = "https://my.t-mobile.com/Login/?r=1"

agent.pluggable_parser.default = Mechanize::Download
agent.pluggable_parser.pdf = Mechanize::FileSaver
# agent.get('http://example.com/foo').save('a_file_name')



tmp = agent.get(url)
form = tmp.forms[0]
form.add_field!("Login1:chkRemember","on")

parameters.keys.each { |key|
  begin 
    form.set_fields( key => parameters[key] )
  rescue Exception => e 
    puts "Error with #{e}"
  end
}

startpage = agent.submit( form )
billing = startpage.links.find_all { |i| i.to_s =~ /billing/i }[0]
bpage = agent.click (billing)






