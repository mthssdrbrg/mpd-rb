# encoding: utf-8

module MPD
  class CommandError < StandardError

    attr_reader :code, :index, :command

    def initialize(error)
      error_matches = error.match(ERROR_REGEXP)
      super(error_matches[:message])

      @code = error_matches[:code].to_i
      @index = error_matches[:index].to_i
      @command = error_matches[:command].to_sym
    end

    private

    ERROR_REGEXP = /^ACK \[(?<code>\d+)\@(?<index>\d+)\] \{(?<command>.*)\} (?<message>.+)$/.freeze
  end

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

require 'mpd/protocol/command'
require 'mpd/protocol/responses'
