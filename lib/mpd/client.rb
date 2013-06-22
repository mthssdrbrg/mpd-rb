module MPD
  class Client
    def self.command(cmd, options = {})
      define_method(cmd) do |*args|
        command = Protocol::Command.new(cmd, @command_transposer, *args)
        raw_response = @socket.execute(command)

        case options[:response]
        when :hash
          response = Protocol::HashResponse.new(raw_response)
          @transposer.transpose(response.parse)
        when :list
          response = Protocol::ListResponse.new(raw_response)
          @transposer.transpose(response.parse)
        else
          Protocol::Response.new(raw_response).parse
        end
      end
    end

    command :next
    command :previous
    command :pause
    command :stop
    command :play_id
    command :consume
    command :clear_error
    command :add
    command :clear
    command :delete
    command :delete_id
    command :move
    command :move_id

    command :stats, :response => :hash
    command :status, :response => :hash
    command :current_song, :response => :hash
    command :add_id, :response => :hash
    command :playlist_info, :response => :list

    def initialize(socket)
      @socket = Protocol::ConvenienceSocket.new(socket)
      @transposer = Protocol::RubyesqueTransposer.new
      @command_transposer = Protocol::MpdesqueTransposer.new
    end
  end
end
