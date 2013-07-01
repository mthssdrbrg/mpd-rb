module MPD
  module CommandDsl
    def command(cmd, options = {})
      define_method(cmd) do |*args|
        cmd = options[:raw] || cmd
        command = Protocol::Command.new(cmd, *args)
        raw_response = socket.execute(command)
        response_type = options[:response].to_s.capitalize
        response_clazz = "#{response_type}Response"
        response = Protocol.const_get(response_clazz).new(raw_response, options)

        if response.successful?
          response.body
        else
          raise response.error
        end
      end
    end
  end
end
