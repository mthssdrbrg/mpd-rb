module MPD
  module Protocol
    class Command
      def initialize(command, *arguments)
        @command = command
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
        @arguments.map { |a| transpose(a) }
      end

      def transpose(value)
        if !!value == value
          transpose_boolean(value)
        elsif value.is_a?(Range)
          transpose_range(value)
        elsif value.respond_to?(:match) && value.match(HAS_WHITESPACE)
          "\"#{value}\""
        else
          value
        end
      end

      def transpose_range(range)
        [range.min, range.max].join(COLON)
      end

      def transpose_boolean(value)
        value ? ONE : ZERO
      end

      private

      ONE = '1'.freeze
      ZERO = '0'.freeze
      HAS_WHITESPACE = /.\s./.freeze
    end
  end
end
