#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require "bundle/bundler/setup"
require "alfred"
require 'excon'
require 'json'

GREEN_ICON = {:type => "default", :name => "status_green.png"}
RED_ICON = {:type => "default", :name => "status_red.png"}
ENVIRONMENTS = %w{production development}

api_status = Excon.get('https://status.heroku.com/api/v3/current-status')

def current_status_icon(api_status, environment)
  if api_status.status == 200
    response = JSON.parse(api_status.body)
    return response['status'][environment.capitalize] == 'green' ? GREEN_ICON : RED_ICON
  end
end

def handle_errors(api_status)
  api_status.status != 200 ? 'Error retrieving Heroku platform status' : ''
end

Alfred.with_friendly_error do |alfred|
  fb = alfred.feedback

  ENVIRONMENTS.each do |environment|
    fb.add_item({
      :title    => environment.capitalize,
      :icon     => current_status_icon(api_status, environment),
      :subtitle => handle_errors(api_status)
    })
  end

  puts fb.to_xml(ARGV)
end
