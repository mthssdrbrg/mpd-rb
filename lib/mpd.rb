# encoding: utf-8

module MPD
  MPDError = Class.new(StandardError)
end

require 'mpd/protocol'
require 'mpd/command_dsl'
require 'mpd/client'
require 'mpd/player'
require 'mpd/io'
