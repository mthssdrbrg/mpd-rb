module MPD
  module Protocol
    class Response

      attr_reader :raw

      def initialize(raw = [], options = {})
        @raw = raw
      end

      def successful?
        !failure?
      end
      alias_method :success?, :successful?
      alias_method :ok?, :successful?

      def failure?
        raw.nil? || (raw.one? && raw.first.match(ERROR))
      end
      alias_method :error?, :failure?

      def body
        successful? ? :ok : error
      end

      def error
        CommandError.new(raw.first) if error?
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

    class SingleValueResponse < HashResponse
      def body
        return nil if raw.empty?
        successful? ? extract_pair(raw.first).last : error
      end
    end

    class ListResponse < HashResponse

      attr_reader :delimiter

      def initialize(raw, options = {})
        super(raw, options)
        @delimiter = options[:delimiter] || :file
      end

      def body
        if successful?
          extracted = raw.map(&method(:extract_pair))
          separate(delimiter, extracted) { |slice| Hash[slice] }
        else
          error
        end
      end

      private

      def separate(delim, from, &transform)
        [].tap do |memo|
          while from.any? do
            index = rindex_of(delim, from)
            slice = from.slice!(index, from.length)
            memo.unshift(transform.call(slice))
          end
        end
      end

      def rindex_of(delim, list)
        list.rindex { |(k, v)| k == delim }
      end
    end
  end
end
