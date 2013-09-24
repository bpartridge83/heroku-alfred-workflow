#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require "bundle/bundler/setup"
require "alfred"
require 'excon'
require 'json'
require 'base64'
require 'netrc'

n = Netrc.read
user, token = n["api.heroku.com"]
auth64 = Base64.encode64("#{user}:#{token}").gsub("\n", "")

response = Excon.get('https://api.heroku.com/apps', :headers => {'Authorization' => "Basic #{auth64}"})

Alfred.with_friendly_error do |alfred|
  fb = alfred.feedback

  applications = JSON.parse(response.body)

  applications.each do |application|
    fb.add_item({
      :title    => application['name'],
      :subtitle => "Region: #{application['region']},  Dynos: #{application['dynos']},  Workers: #{application['workers']}",
      :autcomplete => application['name'],

    })
  end

  puts fb.to_xml(ARGV)
end
