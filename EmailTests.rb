#!/usr/bin/ruby
#
# 
# A simple script for mailing out results from a simulation
#

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  LIBRARIES  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

require "base64"
require 'ostruct'
require 'optparse'
require 'net/smtp'
require 'tlsmail'


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  GLOBALS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

SENDGRID_ADDRESS = "smtp.sendgrid.net"
SENDGRID_PORT    = "587"
SENDGRID_DOMAIN  = "heroku.com"

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  METHODS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

def parse(argv)
  options         = OpenStruct.new
  options.from    = "cs@anonymizerinc.com"
  options.to      = nil
  options.dir     = nil
  options.html    = nil
  options.subject = "Test result"
  options.sguser  = ENV['SENDGRID_USERNAME']
  options.sgpass  = ENV['SENDGRID_PASSWORD']

  OptionParser.accept(Dir, /^(\S+.*)$/ ) do |dir|
    Dir.new( File.expand_path( dir ) )
  end
  OptionParser.accept(File, /^(\S+.*)$/ ) do |file|
    File.open(File.expand_path(file))
  end

  op = OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"
    opts.separator ""
    opts.separator "Specific options:"

    # Mandatory argument.
    opts.on("-u", "--from FROMADDRESS", String, "From email address" ) do |from|
      options.from = from
    end
    # Mandatory argument.
    opts.on("-t", "--to TOADDRESS", String, "To email address " ) do |to|
      options.to = to
    end
    opts.on("-D", "--testdir DIR" , Dir , "Directory to test" ) do |dir|
      options.dir = dir.path
    end
    opts.on("-U", "--sgriduser USER" , String , "Send grid user " ) do |sguser|
      opts.sguser = sguser
    end

    opts.on("-P", "--sgpass USER" , String , "Send grid password " ) do |sgpass|
      options.sguser = sgpass
    end

    opts.on("-H" , "--html HTMLFILE" , File, "Optional HTML file" ) do |html|
      options.html = html.path
    end

  end
  begin
    op.parse!(argv)
    raise OptionParser::ParseError.new("--to email address required")  if options.to.nil?
    raise OptionParser::ParseError.new("--dir directory required or --html output_results required " ) if options.dir.nil? && options.html.nil?
    raise OptionParser::ParseError.new("--sguser required" ) if options.sguser.nil?
    raise OptionParser::ParseError.new("--sgpass required" ) if options.sgpass.nil?
  rescue OptionParser::ParseError => e
    STDERR.puts e.message, "\n", op
    exit(-1)
  end
  options
end

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  MAIN  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

opts = parse(ARGV)

message =<<MESSAGE
From: #{opts.from}
To: #{opts.to}
MIME-Version: 1.0
Content-type: text/html;
       charset="UTF-8"
Content-Transfer-Encoding: base64
Subject: #{opts.subject}


MESSAGE

tmp = File.read(opts.html)
tmp = Base64.encode64(tmp)
message += tmp

Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
Net::SMTP.start( SENDGRID_ADDRESS,
          SENDGRID_PORT,
          SENDGRID_DOMAIN,
          opts.sguser,
          opts.sgpass,
          :plain
          ) do |smtp|
  smtp.send_message( message, opts.from , opts.to )
end
