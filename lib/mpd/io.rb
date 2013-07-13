# encoding: utf-8

module MPD
  NotConnectedError = Class.new(MPDError)
end

require 'mpd/io/connection'
