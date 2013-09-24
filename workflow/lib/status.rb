#!/usr/bin/env ruby
# encoding: utf-8
#
require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require "bundle/bundler/setup"
require "alfred"
require 'excon'
require 'json'

GREEN_ICON = {:type => "default", :name => "icons/status_green.png"}
RED_ICON = {:type => "default", :name => "icons/status_red.png"}
YELLOW_ICON = {:type => "default", :name => "icons/status_yellow.png"}

ENVIRONMENTS = %w{production development}

module Status

  def self.keyword
    {
      :title    => 'Platform status',
      :subtitle => 'Current API status',
      :autocomplete => 'status'
    }
  end
   
  def self.action(feedback)
    #feedback.add_item({ :title => 'blah' })
    
    api_status = Excon.get('https://status.heroku.com/api/v3/current-status')

    ENVIRONMENTS.each do |environment|
      feedback.add_item({
        :title    => environment.capitalize,
        :icon     => current_status_icon(api_status, environment),
        :subtitle => subtitle(api_status,environment)
      })
    end
  end
end


def current_status_icon(api_status, environment)
  if api_status.status == 200
    response = JSON.parse(api_status.body)
    case response['status'][environment.capitalize]
    when 'green'
      return GREEN_ICON
    when "yellow"
      return YELLOW_ICON
    else
      RED_ICON
    end
  end
end

def subtitle(api_status, environment)
  if api_status.status == 200
    response = JSON.parse(api_status.body)
    if response['issues'].length > 0
      if response['issues'].first["status_#{short_environment(environment)}"] == 'green'
        "No known issues at this time."
      else
        response['issues'].first['title']
      end
    else
      "No known issues at this time."
    end
  else
    handle_errors(api_status)
  end
end

# Map PRODUCTION => PROD and DEVELOPMENT => DEV
def short_environment(environment)
  case environment
  when 'development'
    'dev'
  when 'production'
    'prod'
  end
end

def handle_errors(api_status)
  api_status.status != 200 ? 'Error retrieving Heroku platform status' : ''
end

#Alfred.with_friendly_error do |alfred|
#  fb = alfred.feedback
#
#  ENVIRONMENTS.each do |environment|
#    fb.add_item({
#      :title    => environment.capitalize,
#      :icon     => current_status_icon(api_status, environment),
#      :subtitle => subtitle(api_status,environment)
#    })
#  end
#
#  puts fb.to_xml(ARGV)
#end
