# encoding: utf-8
require 'spec_helper'

module MPD
  describe Player do

    let :player do
      MPD::Player.new(client)
    end

    let :client do
      double(:client)
    end

    describe '#next' do
      it 'tells the client to play the next song in the playlist' do
        client.should_receive(:next)
        player.next
      end
    end

    describe '#previous' do
      it 'tells the client to play the previous song in the playlist' do
        client.should_receive(:previous)
        player.previous
      end
    end

    describe '#pause' do
      it 'pauses playback' do
        client.should_receive(:pause).with(0)
        player.pause
      end
    end

    describe '#playing?' do
      it 'asks the client for status' do
        client.should_receive(:status).and_return({})
        player.playing?
      end

      context 'when client state is :play' do
        it 'is playing' do
          client.stub(:status).and_return({:state => :play})
          player.playing?.should be true
        end
      end

      context 'when client state is :pause' do
        it 'is not playing' do
          client.stub(:status).and_return({:state => :pause})
          player.playing?.should be false
        end
      end

      context 'when client state is :stop' do
        it 'is not playing' do
          client.stub(:status).and_return({:state => :stop})
          player.playing?.should be false
        end
      end
    end

    describe '#toggle' do
      before do
        client.stub(:status).and_return(status)
      end

      context 'player is currently playing' do
        let :status do
          {:state => :play}
        end

        it 'pauses playback' do
          client.should_receive(:pause).with(1)
          player.toggle
        end
      end

      context 'player is paused' do
        let :status do
          {:state => :pause}
        end

        it 'resumes playback' do
          client.should_receive(:pause).with(0)
          player.toggle
        end
      end
    end

    describe '#stop' do
      it 'tells the client to stop' do
        client.should_receive(:stop)
        player.stop
      end
    end

    describe '#status' do
      it 'proxies status from client' do
        client.stub(:status).and_return({:state => :play, :other => :stuff})
        player.status.should == {:state => :play, :other => :stuff}
      end
    end

    describe '#play' do
      context 'with explicit song id' do
        it 'tells client to play song' do
          client.should_receive(:play).with(123)
          player.play(123)
        end
      end

      context 'without song id' do
        before do
          client.stub(:status).and_return(status)
        end

        context 'and player is playing' do
          let :status do
            {:state => :play}
          end

          it 'doesn\'t do anything' do
            client.should_not_receive(:play)
            player.play
          end
        end

        context 'and player is not playing' do
          let :status do
            {:state => :pause}
          end

          it 'starts playback' do
            client.should_receive(:pause).with(0)
            player.play
          end
        end
      end
    end

    describe '#seek' do
      it 'tells the client to seek within the current song' do
        client.should_receive(:seek_current).with(10)
        player.seek(10)
      end
    end

    describe '#consume' do
      context 'when argument is true' do
        it 'enables consume mode' do
          client.should_receive(:consume).with(1)
          player.consume(true)
        end
      end

      context 'when argument is false' do
        it 'disables consume mode' do
          client.should_receive(:consume).with(0)
          player.consume(false)
        end
      end
    end

    describe '#consuming?' do
      it 'asks the client for consuming status' do
        client.should_receive(:status).and_return({})
        player.consuming?
      end

      context 'when consume mode is enabled' do
        it 'returns true' do
          client.stub(:status).and_return(:consume => true)
          player.consuming?.should be true
        end
      end

      context 'when consume mode is disabled' do
        it 'returns false' do
          client.stub(:status).and_return(:consume => false)
          player.consuming?.should be false
        end
      end

      it 'is aliased as #consume?' do
        client.stub(:status).and_return({})
        player.consume?.should == player.consuming?
      end
    end

    describe '#random' do
      context 'when argument is true' do
        it 'enables random mode' do
          client.should_receive(:random).with(true)
          player.random(true)
        end
      end

      context 'when argument is false' do
        it 'disables random mode' do
          client.should_receive(:random).with(false)
          player.random(false)
        end
      end
    end

    describe '#random?' do
      it 'asks the client for random status' do
        client.should_receive(:status).and_return({})
        player.random?
      end

      context 'when random mode is enabled' do
        it 'returns true' do
          client.stub(:status).and_return(:random => true)
          player.random?.should be true
        end
      end

      context 'when random mode is disabled' do
        it 'returns false' do
          client.stub(:status).and_return(:random => false)
          player.random?.should be false
        end
      end
    end

    describe '#volume' do
      context 'when given explicit volume level' do
        it 'tells client to set volume level' do
          client.should_receive(:set_volume).with(78)
          player.volume(78)
        end
      end

      context 'when not given explicit volume level' do
        it 'returns the current volume level' do
          client.should_receive(:status).and_return(:volume => 68)
          player.volume.should == 68
        end
      end
    end

    describe '#single' do
      context 'when argument is true' do
        it 'enables single mode' do
          client.should_receive(:single).with(true)
          player.single(true)
        end
      end

      context 'when argument is false' do
        it 'disables single mode' do
          client.should_receive(:single).with(false)
          player.single(false)
        end
      end
    end

    describe '#single?' do
      it 'asks the client for single status' do
        client.should_receive(:status).and_return({})
        player.single?
      end

      context 'when single mode is enabled' do
        it 'returns true' do
          client.stub(:status).and_return(:single => true)
          player.single?.should be true
        end
      end

      context 'when random mode is disabled' do
        it 'returns false' do
          client.stub(:status).and_return(:single => false)
          player.single?.should be false
        end
      end
    end
  end
end
