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

    class ListResponse < HashResponse

      attr_reader :marker

      def initialize(raw, options = {})
        super(raw, options)
        @marker = options[:marker] || :file
      end

      def body
        if successful?
          extracted = raw.map(&method(:extract_pair))
          separate(marker, extracted) { |slice| Hash[slice] }
        else
          error
        end
      end

      private

      def separate(mark, from, &transform)
        [].tap do |memo|
          while from.any? do
            index = rindex_of(mark, from)
            slice = from.slice!(index, from.length)
            memo.unshift(transform.call(slice))
          end
        end
      end

      def rindex_of(mark, list)
        list.rindex { |(k, v)| k == mark }
      end
    end

    class GroupedResponse < ListResponse

      attr_reader :group_by

      def initialize(raw, options = {})
        super
        @group_by = options[:group_by]
      end

      def body
        if successful?
          extracted = raw.map(&method(:extract_pair))
          result = {}

          unless (index = index_of(group_by, extracted)).zero?
            at_root = extracted.slice!(0, index)

            result[EMPTY_STRING] = separate(marker, at_root) { |slice| Hash[slice] }
          end

          separated = separate(group_by, extracted) { |slice| slice }
          separated.each_with_object(result) do |slice, hash|
            key = slice.shift.last
            hash[key] = separate(marker, slice) { |slice| Hash[slice] }
          end
        end
      end

      private

      def index_of(mark, list)
        list.index { |(k, v)| k == mark }
      end
    end
  end
end
