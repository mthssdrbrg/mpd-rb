require 'mpd/protocol/io'
require 'mpd/protocol/request'
require 'mpd/protocol/response'

module MPD
	module Protocol
		include IO

		DELIMITER = "\t"
		SUFFIX = "\n"

		SUCCESS = /OK\Z/ # /OK[\s?MPD\s?\d\.\d\.\d]?\Z/
		FAILURE = /ACK\s\[\w*\@\d*\]\s\{\w*\}\s.*\Z/

		attr_accessor :version

		def self.command(*commands, &block)
			commands.each do |cmd|
				define_method cmd do |arguments = {}|
					# unless authed?
					request = Request.new(cmd, arguments)
					write_request(request)

					response = read_response
					response
					# end
				end
			end
		end

		def auth
			authed = false

			begin
				hello = read

				self.version = hello.split(' ').last.strip
				authed = true
			rescue
			end

			authed
		end

		def authed?
			@authed
		end

		command :status, :stats, :clearerror, :currentsong

		private

		def write_request(request)
			write(request.serialize)
		end

		def read_response
			raw, done = [], false

			until done do
				line = read

				case line
				when FAILURE
					raw << line.strip
					done = true
					# Raise specific error?
				when SUCCESS
					done = true
				else
					raw << line.strip
				end
			end

			response = Response.new(raw)
			response
		end
		
	end # Protocol
end # MPD
