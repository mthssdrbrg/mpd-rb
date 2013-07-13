# encoding: utf-8

module MPD
  module Io
    class Connection

      attr_reader :version

      def initialize(socket_impl = TCPSocket)
        @socket_impl = socket_impl
        @connected = false
      end

      def connect(host, port)
        if @socket
          @socket.close unless @socket.closed?
          @socket = nil
        end

        @socket = @socket_impl.new(host, port)
        perform_handshake
        @connected = true

        self
      end
      alias_method :reconnect, :connect

      def execute(command)
        ensure_connected
        @socket.puts(command.to_s)

        @socket.each_with_object([]) do |line, memo|
          if footer?(line)
            return memo
          elsif error?(line)
            memo << line.chomp
            return memo
          else
            memo << line.chomp
          end
        end
      end

      def connected?
        !!@connected
      end

      private

      def ensure_connected
        raise NotConnectedError unless connected?
      end

      def footer?(line)
        line.nil? || !!(line.strip.match(Protocol::OK))
      end

      def error?(line)
        !!(line.match(Protocol::ERROR))
      end

      def perform_handshake
        handshake = @socket.gets
        @version = handshake.strip.split(' ').last
      end
    end
  end
end
