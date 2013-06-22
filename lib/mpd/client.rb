module MPD
  class Client
    def self.command(cmd, options = {})
      define_method(cmd) do |*args|
        command = Protocol::Command.new(cmd, @command_transposer, *args)
        raw_response = @socket.execute(command)

        case options[:response]
        when :hash
          response = Protocol::HashResponse.new(raw_response)
          @response_transposer.transpose(response.parse)
        when :list
          response = Protocol::ListResponse.new(raw_response)
          @response_transposer.transpose(response.parse)
        else
          Protocol::Response.new(raw_response).parse
        end
      end
    end

    # Controlling playback
    command :next
    command :pause
    command :play_id
    command :previous
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

    # Querying MPD's status
    command :clear_error
    command :stats, :response => :hash
    command :status, :response => :hash
    command :current_song, :response => :hash

    def initialize(socket)
      @socket = Protocol::ConvenienceSocket.new(socket)
      @response_transposer = Protocol::RubyesqueTransposer.new
      @command_transposer = Protocol::MpdesqueTransposer.new
    end
  end
end
