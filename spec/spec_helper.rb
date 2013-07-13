# encoding: utf-8
require 'simplecov'

SimpleCov.start do
  add_group 'Source', 'lib'
  add_group 'Unit tests', 'spec'
end

require 'mpd'

RSpec.configure do |config|
	config.color_enabled = true
end
