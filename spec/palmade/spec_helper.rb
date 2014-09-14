require 'pp'
require 'rubygems'

require 'rspec'
require 'yaml'
require 'curb'

require 'tempfile'
require 'json'
require 'rack'
require 'curb'

# let's load http_service
require 'palmade/http_service'
# load config from helper
require File.expand_path(File.join(File.dirname(__FILE__),'http_service/http_service_helper'))
