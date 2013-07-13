# encoding: utf-8

module MPD
  class Client
    extend CommandDsl

    # Controlling playback
    command :next
    command :pause
    command :play
    command :play_id
    command :previous
    command :seek
    command :seek_id
    command :seek_current, :raw => :seekcur
    command :stop

    # The current playlist
    command :add
    command :add_id, :response => :single_value
    command :clear
    command :delete
    command :delete_id
    command :move
    command :move_id
    command :playlist_info, :response => :list
    command :swap
    command :swap_id
    command :shuffle

    # Playback options
    command :consume
    command :random
    command :repeat
    command :single
    command :crossfade
    command :volume, :raw => :setvol
    command :mixramp_db
    command :mixramp_delay

    # Querying MPD's status
    command :clear_error
    command :stats, :response => :hash
    command :status, :response => :hash
    command :current_song, :response => :hash

    # The music database
    command :count, :response => :hash
    command :find, :response => :list
    command :find_add
    command :list, :response => :list, :delimiter => :album
    command :update, :response => :single_value
    command :rescan, :response => :single_value

    # Connection settings
    command :close
    command :kill
    command :ping

    attr_reader :connection

    def initialize(options = {})
      @host = options[:host] || 'localhost'
      @port = options[:port] || 6600
      @connection = options[:connection] || MPD::Io::Connection.new
    end

    def connect
      unless @connection.connected?
        @connection.connect(@host, @port)
      end
    end

    def disconnect
      if @connection.connected?
        self.close
        @connection.close
      end
    end
  end
end
