module MPD
  module Protocol
    class Response < Struct.new(:raw)

      def successful?
        !failure?
      end
      alias_method :success?, :successful?

      def failure?
        raw.nil? || (raw.one? && raw.first.match(ERROR))
      end
      alias_method :error?, :failure?

      def body
        successful? ? :ok : error
      end

      def error
        CommandError.new(raw.first)
      end
    end

    class HashResponse < Response

      def body
        return nil if raw.empty?

        if successful?
          Hash[raw.map(&method(:extract_pair))]
        else
          error
        end
      end

      private

      def extract_pair(line)
        key, value = line.split(COLON, 2).map(&:strip)
        key = key.downcase.gsub(DASH, UNDERSCORE).to_sym
        [key, value]
      end
    end

    class ListResponse < HashResponse

      attr_reader :marker

      def initialize(raw, marker = :id)
        super(raw)
        @marker = marker
      end

      def body
        if successful?
          extracted = raw.map(&method(:extract_pair))

          [].tap do |memo|
            while extracted.any? do
              index = extracted.index { |(k, v)| k == marker }
              memo << Hash[extracted.slice!(0, index + 1)]
            end
          end
        else
          error
        end
      end
    end
  end
end
