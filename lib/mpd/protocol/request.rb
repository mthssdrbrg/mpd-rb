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
					serialized << value.to_s
				end

				serialized << Protocol::SUFFIX
				serialized
			end

		end # Request
	end # Protocol
end	# MPD
