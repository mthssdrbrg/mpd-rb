require 'mpd/protocol'

module MPD

	def self.new(*args)
		Client.new(*args)
	end

	class Client
		include MPD::Protocol

		def initialize(options = {})
			self.host = options[:host] || DEFAULT_HOST
			self.port = options[:port] || DEFAULT_PORT
		end

	end
end
