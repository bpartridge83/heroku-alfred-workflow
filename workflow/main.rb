#!/usr/bin/env ruby
# encoding: utf-8

def console_log(msg)
  escape = proc{ |m| m.gsub("'", "'\\\\''") }
  `logger -t 'Alfred Workflow' '#{escape[msg]}'`
end

console_log('Executing main.rb!')

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
console_log('ruby gems required')
require "bundle/bundler/setup"
console_log('bundler required')
require "alfred"
console_log('alfred required')

Alfred.with_friendly_error do |alfred|
  fb = alfred.feedback

  # add an arbitrary feedback
  fb.add_item({
    :uid      => ""                     ,
    :title    => "Just a Test"          ,
    :subtitle => "#{Time.now}"        ,
    :arg      => "A test feedback Item" ,
    :valid    => "yes"                  ,
  })
  
  puts fb.to_xml(ARGV)
end
