require_relative '../lib/racker'
require 'rack/test'

ENV['RACK_ENV'] = 'test'
TEST_ENV = Hash.new
