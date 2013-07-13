module MPD
  module Protocol
    class Response

      attr_reader :raw

      def initialize(raw = [], options = {})
        @raw = raw
      end

      def ok?
        !error?
      end
      alias_method :success?, :ok?

      def error?
        raw.nil? || (raw.one? && raw.first.match(ERROR))
      end

      def decode
        ok? ? :ok : error
      end

      def error
        CommandError.new(raw.first) if error?
      end
    end

    class HashResponse < Response

      def decode
        return nil if raw.empty?

        ok? ? Hash[raw.map(&method(:extract_pair))] : error
      end

      private

      def extract_pair(line)
        key, value = line.split(COLON, 2).map(&:strip)
        key = key.downcase.gsub(DASH, UNDERSCORE).to_sym
        [key, value]
      end
    end

    class SingleValueResponse < HashResponse
      def decode
        return nil if raw.empty?

        ok? ? extract_pair(raw.first).last : error
      end
    end

    class ListResponse < HashResponse

      attr_reader :delimiter

      def initialize(raw, options = {})
        super(raw, options)
        @delimiter = options[:delimiter] || :file
      end

      def decode
        if ok?
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
