module MPD
  NotConnectedError = Class.new(IOError)
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
end

require 'mpd/protocol'
require 'mpd/command_dsl'
require 'mpd/client'
require 'mpd/player'
require 'mpd/io'
