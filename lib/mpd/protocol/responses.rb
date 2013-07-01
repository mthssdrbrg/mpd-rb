module MPD
  module Protocol
    class Response

      attr_reader :raw

      def initialize(raw, options = {})
        @raw = raw
      end

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

      def initialize(raw, options = {})
        super(raw, options)
        @marker = options[:marker] || :file
      end

      def body
        if successful?
          extracted = raw.map(&method(:extract_pair))

          [].tap do |memo|
            while extracted.any? do
              index = extracted.rindex { |(k, v), i| k == marker }
              memo.unshift(Hash[extracted.slice!(index, extracted.length)])
            end
          end
        else
          error
        end
      end
    end
  end
end
