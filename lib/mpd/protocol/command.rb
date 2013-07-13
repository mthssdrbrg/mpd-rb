# encoding: utf-8

module MPD
  module Protocol
    class Command
      attr_reader :command, :arguments

      def initialize(command, *arguments)
        @command = command
        @arguments = arguments.compact
      end

      def to_s
        [mpdified_command, transposed].flatten.join(SPACE)
      end

      def eql?(cmd)
        self.command == cmd.command && self.arguments == cmd.arguments
      end
      alias_method :==, :eql?

      private

      def mpdified_command
        @command.to_s.gsub(UNDERSCORE, EMPTY_STRING)
      end

      def transposed
        @arguments.map { |a| transpose(a) }
      end

      def transpose(value)
        if !!value == value
          !!value ? ONE : ZERO
        elsif value.is_a?(Range)
          [value.min, value.max].join(COLON)
        elsif value.respond_to?(:match) && value.match(HAS_WHITESPACE)
          "\"#{value}\""
        else
          value.to_s
        end
      end

      private

      ONE = '1'.freeze
      ZERO = '0'.freeze
      HAS_WHITESPACE = /.\s./.freeze
    end
  end
end
