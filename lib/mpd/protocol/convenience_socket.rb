module MPD
  module Protocol
    class ConvenienceSocket < Struct.new(:socket)
      def execute(command)
        socket.puts(command.to_s)

        response = []
        each_response_line { |line| response << line }
        response
      end

      private

      def each_response_line
        while true do
          line = socket.gets

          if line.match(OK)
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
