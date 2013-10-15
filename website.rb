#!/usr/bin/env ruby
require 'sinatra'

# Include all the routes
def include_all(dir)
  path = File.path(dir)
  files_to_include = []
  Dir.entries(path).each do |file|
    if file !~ /^\./ and file =~ /\.rb$/
      files_to_include << File.join(path, file)
    end
  end
  files_to_include.sort.each do |full_path|
    require full_path
  end
end
include_all('./routes')