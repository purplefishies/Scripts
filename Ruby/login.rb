#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'mechanize'

agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
agent.log = Logger.new "mech.log"

parameters = {}
parameters["screenid"] = "SIGNON"
parameters["origination"] = "WebCons"
parameters["LOB"] = "Cons"
parameters["u_p"] = "u_p"
parameters["userid"] = "username" 
parameters["password"] = password
parameters["destination"] = "AccountSummary"

agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE

url = "https://online.wellsfargo.com/das/cgi-bin/session.cgi?screenid=SIGNON"

agent.agent.http.ca_file = "/etc/ssl/certs/ca-certificates.crt"

forms = agent.get("https://online.wellsfargo.com/das/cgi-bin/session.cgi?screenid=SIGNON").forms

login_form = forms[1]

login_form.fields.each { |i|
  begin 
    login_form.set_fields( i.name => parameters[i.name] )
  rescue Exception => e 
    puts "Error with #{i}"
  end
}

start = agent.submit( login_form, login_form.button )




#inside.links()

def reset_to_statements(agent)
  inside = agent.get("https://online.wellsfargo.com/das/cgi-bin/session.cgi?screenid=SIGNON_PORTAL_PAUSE" )
  statements = inside.links.find_all { |i| i.to_s =~ /Statements/ }
  statement_page = agent.click( statements[0] )
end


#
# Change to a different set of forms
#
# statement_page.forms[0].fields[0].options.each { |option | 
keep.each { |option | 
  # dir = option.text
  statement_page.forms[0].fields[0].value= option
  puts "Processing #{option.text}"


  subpage = agent.submit( statement_page.forms[0] , statement_page.forms[0].button )

  subpage.links.find_all { |year_link| year_link.to_s =~ /20\d+/ }.each { |year| 
    yearname = year.to_s.encode("UTF-8")
    begin
      dir = File.expand_path("~/WellsFargo/" + yearname + "/" + option.text.encode("UTF-8").gsub(/\s/,"_").gsub(/[\(\)]/,"_"))
      puts "\tYear #{yearname}"
      agent.click( year )
      subpage.links.find_all {|i| i.to_s =~ /\d+\/\d+\/\d+/ }.each {|statement|
        filename = statement.text.split("\n").join(" ").sub(/^.*?(\d+)\/(\d+)\/(\d+)\s.*$/,'\1_\2_\3') + ".pdf"
        tmp = agent.get(statement.uri.to_s)
        download_file = dir + "/" + filename 
        if !File.directory?(dir)
          # Dir.mkdir(dir)
          system("mkdir -p \"#{dir}\"")
        end
        system("mv #{tmp.filename} #{download_file}")
      }
    rescue Exception => e
      puts "Had problem with #{e}, yearname=#{yearname}"
    end
    
  }                             # end year links

  statement_page = reset_to_statements(agent)
}



#
# 
#
dir = File.expand_path("~/WellsFargo")

statement_page.links.find_all {|i| i.to_s =~ /\d+\/\d+\/\d+/ }.each {|statement|
  filename = statement.text.split("\n").join(" ").sub(/^.*?(\d+)\/(\d+)\/(\d+)\s.*$/,'\1_\2_\3') + ".pdf"
  tmp = agent.get(statement.uri.to_s)
  download_file = dir + "/" + filename 
  if !File.directory?(dir)
    Dir.mkdir(dir)
  end
  system("mv #{tmp.filename} #{download_file}")
}



sform = statement_page.forms[0]
sform.fields[0].options
selectlist = sform.fields[0]
selectlist.value = selectlist.options.first
#selectlist.options().last
newstatement_page = agent.submit( sform, sform.button )

month_statement = newstatement_page.links.find_all { |i| i.to_s =~ Regexp.new("05/31/13") }[0]


agent.get(month_statement.uri.to_s)

filename = "May2013.pdf"
download_file = "~/WellsFargo/" + filename 
lastfile = Dir["online.wellsfargo.com/das/cgi-bin/*"].first
system("mv #{lastfile} #{download_file}")


# statement_page.links.find_all { |i| i.to_s =~ Regexp.new("\d+\/\d+\/\d+") }
#parameters.keys.each { |i|
#  login_form.set_fields( i => parameters[i] )
#}
#Checking account
#//*[@id="DDATransactionTable"]/tbody/tr[4]
#//*[@id="DDATransactionTable"]/tbody/tr[4]
# Statements and documents
# //*[@id="listOfStatements"]/tbody/tr[1] # Parent one
# //*[@id="listOfStatements"]/tbody/tr[2] # Actual statements
#//*[@id="listOfStatements"]/tbody
#html = agent.posta(url, parameters).body
#tmp = agent.post(url,parameters )
