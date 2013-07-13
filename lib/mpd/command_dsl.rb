# encoding: utf-8

module MPD
  module CommandDsl
    def command(cmd, options = {})
      define_method(cmd) do |*args|
        command_symbol = options[:raw] || cmd
        command = Protocol::Command.new(command_symbol, *args)
        raw_response = connection.execute(command)
        response_type = options[:response].to_s.split(UNDERSCORE).map(&:capitalize).join
        response_clazz = "#{response_type}Response"
        Protocol.const_get(response_clazz).new(raw_response, options)
      end
    end

    UNDERSCORE = '_'.freeze
  end
end
