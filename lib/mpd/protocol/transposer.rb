module MPD
  module Protocol
    TRANSPOSE_BOOLEAN = [:repeat, :random, :consume, :single, :xfade].freeze
    TRANSPOSE_SYMBOL = [:state].freeze
    TRANSPOSE_FLOAT = [:mixrampdelay].freeze

    class RubyesqueTransposer
      def transpose(thing)
        if thing.is_a?(Hash)
          transpose_hash(thing)
        elsif thing.respond_to?(:map)
          thing.map { |t| transpose_hash(t) }
        else
          thing
        end
      end

      def transpose_boolean(value)
        value.to_i > 0 ? true : false
      end

      def transpose_float(value)
        value == NAN ? Float::NAN : Float(value)
      end

      private

      INTEGER_REGEXP = /^\d+$/.freeze
      FLOAT_REGEXP = /^\d+\.\d+$/.freeze
      NAN = 'nan'.freeze

      def transform(value)
        case value
        when INTEGER_REGEXP
          Integer(value)
        when FLOAT_REGEXP
          Float(value)
        else
          value
        end
      end

      def transpose_hash(hash)
        hash.each do |key, value|
          if TRANSPOSE_BOOLEAN.include?(key)
            hash[key] = transpose_boolean(value)
          elsif TRANSPOSE_SYMBOL.include?(key)
            hash[key] = value.to_sym
          elsif TRANSPOSE_FLOAT.include?(key)
            hash[key] = transpose_float(value)
          else
            hash[key] = transform(value)
          end
        end
      end
    end

    class MpdesqueTransposer
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
