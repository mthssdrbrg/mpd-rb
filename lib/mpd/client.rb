module MPD
  class Client
    def self.command(cmd, options = {})
      define_method(cmd) do |*args|
        cmd = options[:raw] || cmd
        command = Protocol::Command.new(cmd, @command_transposer, *args)
        raw_response = @socket.execute(command)

        case options[:response]
        when :hash
          response = Protocol::HashResponse.new(raw_response)
          if response.successful?
            @response_transposer.transpose(response.parse)
          else
            error = response.parse
            raise error
          end
        when :list
          response = Protocol::ListResponse.new(raw_response)
          if response.successful?
            @response_transposer.transpose(response.parse)
          else
            error = response.parse
            raise error
          end
        else
          response = Protocol::Response.new(raw_response)
          if response.successful?
            response.parse
          else
            error = response.parse
            raise error
          end
        end
      end
    end

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

    def initialize(socket)
      @socket = Protocol::ConvenienceSocket.new(socket)
      @response_transposer = Protocol::RubyesqueTransposer.new
      @command_transposer = Protocol::MpdesqueTransposer.new
    end
  end
end
