#!/usr/bin/ruby

class Process
  def restart_au
    if is_alive?()
      kill_au()
    end
    start_au()
  end

  def stop_au
    processes = IO.popen("ps -ef" ).readlines()
    au = processes.find_all { |i| i =~ /Anonymizer/ }
    if !au.empty?
      pid = au[0].split(" ")[1].to_i()
      Process.kill("TERM",pid )
    end
  end

  def is_alive?
    processes = IO.popen("ps -ef" ).readlines()
    au = processes.find_all { |i| i =~ /Anonymizer/ }
    ifconfig = IO.popen("ifconfig").readlines()
    ppp = ifconfig.find_all { |i| i =~ /^\s*ppp/ }
    return !au.empty? && !ppp.empty?
  end

  def start_au
    system("open \"/Applications/Anonymizer Universal.app\"")
  end
end
