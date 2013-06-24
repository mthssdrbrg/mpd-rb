module MPD
  module ConversionDsl
    def transform(type, &block)
      @transforms ||= {}
      @transforms[type] = block
    end

    def conversion(*arguments)
      @conversions ||= {}
      options = arguments.pop
      arguments.each { |key| @conversions[key] = options[:to] }
    end

    def ignore(*keys)
      @exclusions ||= []
      @exclusions.concat(keys)
    end
  end

  class Converter
    include ConversionDsl

    def initialize(&block)
      if block
        if block.arity.zero?
          yield
        else
          yield self
        end
      end
    end

    def self.load(file)
      contents = File.read(file)
      Converter.new.tap { |c| c.instance_eval(contents, file) }
    end

    def convert(hash)
      hash.each do |key, value|
        next if @exclusions && @exclusions.include?(key)

        if (to = @conversions[key])
          hash[key] = @transforms[to].call(value)
        elsif value.match(INTEGER_REGEXP)
          hash[key] = value.to_i
        end
      end
    end

    private

    INTEGER_REGEXP = /^\d+$/.freeze
  end
end
