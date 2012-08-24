module MPD
  module Protocol
    class Response

    	attr_reader :raw, :payload

    	def initialize(raw)
    		@raw = raw
        deserialize!
    	end

      def deserialize!
        @payload = deserialize
      end

      private

    	def deserialize
    		attrs = {}

    		raw.each do |r|
          key, value = r.split(":")
    			attrs[format_attribute(key).to_sym] = value.strip
    		end

        attrs
    	end

      def format_attribute(attribute)
        attribute.downcase.gsub('-', '_')
      end

    end # Response
  end # Protocol
end # MPD
