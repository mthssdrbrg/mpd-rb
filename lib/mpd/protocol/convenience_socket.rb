module MPD
  module Protocol
    class ConvenienceSocket < Struct.new(:socket)
      def execute(command)
        socket.puts(command.to_s)

        response = []
        each_response_line { |line| response << line }
        response
      end

      def handshake
        initial = socket.gets
        initial.split(SPACE).last
      end

      def close
        socket.close unless socket.closed?
      end

      private

      def each_response_line
        while true do
          line = socket.gets

          if !line || line.match(OK)
            break
          elsif line.match(ERROR)
            yield line.chomp
            break
          else
            yield line.chomp
          end
        end
      end
    end
  end
end
