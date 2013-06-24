module MPD
  module Protocol
    ERROR = /^ACK \[\d+@\d+\] \{.+\}/.freeze
    OK = /^OK/.freeze

    DASH = '-'.freeze
    COLON = ':'.freeze
    SPACE = ' '.freeze
    UNDERSCORE = '_'.freeze
    EMPTY_STRING = ''.freeze

    ERROR_MAPPINGS = {
      1  => 'ACK_ERROR_NOT_LIST',
      2  => 'ACK_ERROR_ARG',
      3  => 'ACK_ERROR_PASSWORD',
      4  => 'ACK_ERROR_PERMISSION',
      5  => 'ACK_ERROR_UNKNOWN',
      50 => 'ACK_ERROR_NO_EXIST',
      51 => 'ACK_ERROR_PLAYLIST_MAX',
      52 => 'ACK_ERROR_SYSTEM',
      53 => 'ACK_ERROR_PLAYLIST_LOAD',
      54 => 'ACK_ERROR_UPDATE_ALREADY',
      55 => 'ACK_ERROR_PLAYER_SYNC',
      56 => 'ACK_ERROR_EXIST'
    }.freeze
  end
end

require 'mpd/protocol/command'
require 'mpd/protocol/responses'
require 'mpd/protocol/convenience_socket'
require 'mpd/protocol/transposer'
