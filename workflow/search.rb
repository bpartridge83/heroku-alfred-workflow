#!/usr/bin/env ruby
# encoding: utf-8
#
# Main Gateway to Heroku Workflow

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require "bundle/bundler/setup"
require "alfred"

# Require all the files in lib
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

Alfred.with_friendly_error do |alfred|
  query = ARGV.join(" ").strip.split
  fb = alfred.feedback
  
  case query
  when []
    fb.add_item( Status.keyword )
    fb.add_item( Apps.keyword )
  else
    #Status.action(fb)
    Object.const_get(query[0].capitalize).action(fb)
    #raise query[0].inspect
  end

  puts fb.to_xml #(ARGV)

end
