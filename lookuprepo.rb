#!/usr/bin/env ruby


# doctest: testing support URI
#
# >> a = android_support_to_uri "com.android.support:support-v4:23.3.0"
# >> a =~ /^.*extras\/android\/m2repository.*$/
# => 0
# >> begin ; android_support_to_uri(nil); rescue Exception => e ; false; end
# => false
def android_support_to_uri(name)
  raise "No ANDROID_SDK_HOME set" unless ENV["ANDROID_SDK_HOME"]
  raise "No name" unless !name.nil?
  ( path, name , version) = name.split(":")
  path.gsub!("\.",'/')
  "file://" + ENV["ANDROID_SDK_HOME"] + "/extras/android/m2repository/#{path}/#{name}/#{version}/#{name}-#{version}.aar"
end

# doctest: Maven URI
# 
# >> a = maven_to_uri("com.google.guava:guava:13.0")
# >> a =~ /^.*central\.maven\.org.*$/
# => 0
# >> a = maven_to_uri("com.github.bumptech.glide:glide:3.6.1")
# >> a =~ /^.*com\/github.*$/
# => 0
def maven_to_uri(name)
  raise "No ANDROID_SDK_HOME set" unless ENV["ANDROID_SDK_HOME"]
  raise "No name" unless !name.nil?
  ( path, nname , version) = name.split(":")
  #byebug
  path.gsub!("\.",'/')
  "http://central.maven.org/maven2/#{path}/#{nname}/#{version}/#{nname}-#{version}.jar"
end


if __FILE__ == $PROGRAM_NAME
  if ARGV[0] =~ /com\.android\.support/
    puts android_support_to_uri( ARGV[0] )
  else
    puts maven_to_uri( ARGV[0] )
  end 
end





