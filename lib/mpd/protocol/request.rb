module MPD
	module Protocol
		class Request

			attr_reader :command, :arguments, :serialized

			def initialize(command, arguments = {})
				@command = command
				@arguments = arguments
			end

			def serialize
				serialized = command.to_s
    		
				arguments.each do |key, value|
					serialized << Protocol::DELIMITER
					serialized << format_argument(value)
				end

				serialized << Protocol::SUFFIX
				serialized
			end

			private

			def format_argument(arg)
				arg.to_s.include?(' ') ? "\"#{arg.to_s}\"" : arg.to_s
			end

		end # Request
	end # Protocol
end	# MPD
