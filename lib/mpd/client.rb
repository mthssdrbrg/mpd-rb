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
    command :add_id, :response => :hash
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
    command :update, :response => :hash
    command :rescan, :response => :hash
    command :count, :response => :hash

    # Connection settings
    command :close
    command :kill
    command :ping

    attr_reader :protocol_version

    def initialize(options = {})
      @host = options[:host] || 'localhost'
      @port = options[:port] || 6600
      @socket_class = options[:socket_class] || TCPSocket
      @connected = false
    end

    def connect
      unless @connected
        tcp_socket = @socket_class.new(@host, @port)
        @socket = Protocol::ConvenienceSocket.new(tcp_socket)
        @protocol_version = @socket.handshake
        @connected = true
      end

      self
    end

    def disconnect
      if @connected
        self.close
        @socket.close
      end
    end

    private

    def socket
      @socket
    end
  end
end
