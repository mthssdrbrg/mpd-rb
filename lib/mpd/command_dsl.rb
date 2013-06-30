module MPD
  module CommandDsl
    def command(cmd, options = {})
      define_method(cmd) do |*args|
        cmd = options[:raw] || cmd
        command = Protocol::Command.new(cmd, *args)
        raw_response = socket.execute(command)
        response_clazz = "#{options[:response].to_s.capitalize}Response"
        response = Protocol.const_get(response_clazz).new(raw_response)

        if response.successful?
          response.body
        else
          raise response.body
        end
      end
    end
  end
end
