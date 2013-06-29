# encoding: utf-8

require 'spec_helper'
require 'mpd/client/client_shared'

module MPD
  describe Client do
    include_context 'client setup'

    before do
      client.connect
    end

    context 'Querying MPD\'s status' do
      describe '#clear_error' do
        it_behaves_like 'a simple command', :clear_error, 'clearerror'
      end

      describe '#status' do
        let :response do
          [
            "volume: 100\n",
            "repeat: 0\n",
            "random: 0\n",
            "single: 0\n",
            "consume: 0\n",
            "playlist: 3\n",
            "playlistlength: 1\n",
            "xfade: 0\n",
            "mixrampdb: 0.000000\n",
            "mixrampdelay: nan\n",
            "state: stop\n",
            "song: 0\n",
            "songid: 0\n",
            "OK\n"
          ]
        end

        it 'sends a \'status\' command to protocol socket' do
          socket.should_receive(:puts).with('status')
          socket.stub(:gets).and_return(*response)
          client.status
        end

        it 'returns a hash with status information' do
          socket.stub(:puts).with('status')
          socket.stub(:gets).and_return(*response)
          client.status.should == {
            volume: '100',
            repeat: '0',
            random: '0',
            single: '0',
            consume: '0',
            playlist: '3',
            playlistlength: '1',
            xfade: '0',
            mixrampdb: '0.000000',
            mixrampdelay: 'nan',
            state: 'stop',
            song: '0',
            songid: '0'
          }
        end
      end

      describe '#stats' do
        let :response do
          [
            "artists: 23\n",
            "albums: 27\n",
            "songs: 270\n",
            "uptime: 4560\n",
            "playtime: 66\n",
            "db_playtime: 77570\n",
            "db_update: 1371762307\n",
            "OK\n"
          ]
        end

        before do
          socket.stub(:puts).with('stats')
          socket.stub(:gets).and_return(*response)
        end

        it 'sends a \'stats\' command to socket' do
          socket.should_receive(:puts).once
          client.stats
        end

        it 'returns a hash with statistics' do
          client.stats.should == {
            :artists => '23',
            :albums => '27',
            :songs => '270',
            :uptime => '4560',
            :playtime => '66',
            :db_playtime => '77570',
            :db_update => '1371762307'
          }
        end
      end

      describe '#current_song' do
        let :response do
          [
            "file: 19-gang_starr-next_time-dsp_int.mp3\n",
            "Last-Modified: 2011-06-22T22:23:56Z\n",
            "Time: 186\n",
            "Artist: Gang Starr\n",
            "Title: Next Time\n",
            "Album: Moment Of Truth\n",
            "Track: 19\n",
            "Date: 1998\n",
            "Genre: Hip-Hop\n",
            "Pos: 0\n",
            "Id: 0\n",
            "OK\n"
          ]
        end

        before do
          socket.stub(:puts).with('currentsong')
          socket.stub(:gets).and_return(*response)
        end

        it 'sends the \'currentsong\' command to socket' do
          socket.should_receive(:puts).with('currentsong')
          client.current_song
        end

        it 'returns a hash with song attributes' do
          song = client.current_song

          song[:artist].should == 'Gang Starr'
          song[:title].should == 'Next Time'
          song[:album].should == 'Moment Of Truth'
          song[:track].should == '19'
          song[:genre].should == 'Hip-Hop'
          song[:pos].should == '0'
          song[:id].should == '0'
          song[:time].should == '186'
          song[:file].should == "19-gang_starr-next_time-dsp_int.mp3"
          song[:last_modified].should == "2011-06-22T22:23:56Z"
        end
      end
    end
  end
end
