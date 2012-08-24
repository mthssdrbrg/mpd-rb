require 'socket'

module MPD
	module Protocol
		module IO

			DEFAULT_HOST = 'localhost'
			DEFAULT_PORT = 6600

			attr_accessor :socket, :host, :port

			def connect(host, port)
				raise ArgumentError, "No host or port specified" unless host && port
				self.host = host || DEFAULT_HOST
				self.port = port || DEFAULT_PORT
				self.socket = TCPSocket.new(host, port)
			end

			def disconnect
				self.socket.close rescue nil
				self.socket = nil
			end

			def write(data)
				self.socket.write(data)
			rescue
				self.disconnect
				raise SocketError, "unable to write: #{$!.message}"
			end

			def read
				self.socket.gets
			rescue
				self.disconnect
				raise SocketError, "unable to read: #{$!.message}"
			end

		end
	end
end
