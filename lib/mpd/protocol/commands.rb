module MPD
  module Protocol
    class Command
      def initialize(command, transposer, *arguments)
        @command = command
        @transposer = transposer
        @arguments = arguments.compact
      end

      def to_s
        [mpdified_command, transposed].flatten.join(SPACE)
      end

      private

      def mpdified_command
        @command.to_s.gsub(UNDERSCORE, EMPTY_STRING)
      end

      def transposed
        @arguments.map { |a| @transposer.transpose(a) }
      end
    end
  end
end
