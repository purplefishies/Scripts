#!/usr/bin/env ruby

require 'net/ftp'
require 'ostruct'
require 'optparse'

options         = OpenStruct.new
options.user = 'accessioproduct'
options.host = 'accesio.com'
options.password = ''
options.file = nil
options.latest = nil
options.remote = 'AIOUSB-Latest.tar.gz'

op = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.separator ""
  opts.separator "Specific options:"

  OptionParser.accept(File, /^(\S+.*)$/ ) do |file|
    File.open(File.expand_path(file))
  end

  opts.on("-u", "--user USER", String, "User" ) do |from|
    options.user = from
  end
  opts.on("-H", "--host USER", String, "Host" ) do |from|
    options.host = from
  end
  opts.on("-p", "--password PASSWORD", String, "Password" ) do |from|
    options.password = from
  end
  opts.on("-f", "--file PASSWORD", File, "File to upload" ) do |file|
    options.file = file
  end
  opts.on("-L", "--latest") do 
    options.latest = true
  end
  opts.on("-R", "--remote", String, "Remote file name" ) do |remote|
    options.remote = remote
  end

end

begin
  op.parse!(ARGV)
  Net::FTP.open( options.host ) do |ftp|
    tmp = ftp.login( options.user, options.password ) 
    ftp.chdir('webspace/httpdocs/files/forever')
    #puts ftp.list("*")
      puts "Uploading '#{options.file.to_path}'"
    retval = ftp.putbinaryfile( options.file )
    if options.latest  
      puts "Uploading '#{options.file.to_path} to '#{options.remote}'"
      ftp.putbinaryfile( options.file , options.remote )     
      ftp.chdir('../packages')
      puts "Uploading '#{options.file.to_path} to '../packages/#{options.remote}'"
      ftp.putbinaryfile( options.file , options.remote )     
    end
  end
rescue OptionParser::ParseError => e 
  STDERR.puts e.message,"\n", op
  exit(-1)
rescue Net::FTPPermError => e 
  STDERR.puts e.message,"\n"
  exit(-1)
end

 
