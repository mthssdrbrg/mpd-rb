module MPD
  class Player
    def initialize(client)
      @client = client
    end

    def next
      @client.next
    end

    def previous
      @client.previous
    end

    def pause
      @client.pause(0)
    end

    def playing?
      status = @client.status
      case status[:state]
      when :play then true
      when :pause, :stop then false
      end
    end

    def toggle
      if playing?
        @client.pause(1)
      else
        @client.pause(0)
      end
    end

    def stop
      @client.stop
    end

    def status
      @client.status
    end

    def play(song_id = nil)
      if song_id
        @client.play(song_id)
      else
        @client.pause(0) unless playing?
      end
    end

    def seek(time)
      @client.seek_current(time)
    end

    def consume(flag)
      @client.consume(flag ? 1 : 0)
    end

    def consuming?
      status = @client.status
      !!status[:consume]
    end
    alias_method :consume?, :consuming?

    def random(flag)
      @client.random(flag)
    end

    def random?
      status = @client.status
      !!status[:random]
    end

    def single(flag)
      @client.single(flag)
    end

    def single?
      status = @client.status
      !!status[:single]
    end

    def volume(level = nil)
      if level
        @client.set_volume(78)
      else
        status = @client.status
        status[:volume]
      end
    end
  end
end
