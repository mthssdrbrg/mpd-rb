module MPD
  module Protocol
    ERROR = /^ACK \[\d+@\d+\] \{.+\}/.freeze
    OK = /^OK/.freeze

    DASH = '-'.freeze
    COLON = ':'.freeze
    SPACE = ' '.freeze
    UNDERSCORE = '_'.freeze
    EMPTY_STRING = ''.freeze
  end
end

require 'mpd/protocol/commands'
require 'mpd/protocol/responses'
require 'mpd/protocol/convenience_socket'
require 'mpd/protocol/transposer'
