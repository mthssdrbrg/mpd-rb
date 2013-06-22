require 'spec_helper'

module MPD
  describe Client do

    let :client do
      MPD::Client.new(socket)
    end

    let :socket do
      mock(:socket)
    end

    shared_examples 'a simple command' do |command, expected, *args|
      before do
        socket.stub(:puts).with(expected)
        socket.stub(:gets).and_return("OK\n")
      end

      it "sends a '#{command}' command to socket" do
        socket.should_receive(:puts).once
        client.send(command, *args)
      end

      context 'on successful command' do
        it 'returns :ok' do
          client.send(command, *args).should == :ok
        end
      end

      context 'on erroneous command' do
        it 'raises a CommandError' do
          socket.stub(:gets).and_return("ACK [50@0] {#{command}} error message")
          expect { client.send(command, *args) }.to raise_error(CommandError, /ACK \[50@0\] \{#{command}\}/)
        end
      end
    end

    context 'Controlling playback' do
      describe '#next' do
        it_behaves_like 'a simple command', :next, 'next'
      end

      describe '#previous' do
        it_behaves_like 'a simple command', :previous, 'previous'
      end

      describe '#stop' do
        it_behaves_like 'a simple command', :stop, 'stop'
      end

      describe '#pause' do
        context 'when given true' do
          it_behaves_like 'a simple command', :pause, 'pause 1', true
        end

        context 'when given false' do
          it_behaves_like 'a simple command', :pause, 'pause 0', false
        end
      end

      describe '#play_id' do
        it_behaves_like 'a simple command', :play_id, 'playid 123', 123
      end
    end

    context 'The current playlist' do
      describe '#add' do
        it_behaves_like 'a simple command', :add, 'add random_existing_music_file.mp3', 'random_existing_music_file.mp3'
      end

      describe '#add_id' do
        let :file_uri do
          'random_existing_music_file.mp3'
        end

        before do
          socket.stub(:puts)
          socket.stub(:gets).and_return("Id: 12\n", "OK\n")
        end

        context 'successful command' do
          context 'with explicit position' do

            let :position do
              10
            end

            it 'sends an \'addid\' command with position to socket' do
              socket.should_receive(:puts).with("addid #{file_uri} 10")
              client.add_id(file_uri, position)
            end

            it 'returns a hash containing a single key-value pair' do
              client.add_id(file_uri, position).should == {:id => 12}
            end
          end

          context 'without explicit position' do
            it 'sends an \'add_id\' without position to socket' do
              socket.should_receive(:puts).with("addid #{file_uri}")
              client.add_id(file_uri)
            end

            it 'returns a hash containing a single key-value pair' do
              client.add_id(file_uri).should == {:id => 12}
            end
          end
        end

        context 'erroneous command' do
          it 'raises a CommandError' do
            socket.stub(:gets).and_return("ACK [50@0] {addid} Not found\n")
            expect { client.add_id(file_uri) }.to raise_error(CommandError, /ACK \[50@0\] \{addid\}/)
          end
        end
      end

      describe '#clear' do
        it_behaves_like 'a simple command', :clear, 'clear'
      end

      describe '#delete' do
        context 'with position' do
          it 'sends a \'delete\' command with given position' do
            socket.should_receive(:puts).with('delete 10')
            socket.stub(:gets).and_return("OK\n")

            client.delete(10)
          end
        end

        context 'with range' do
          it 'sends a \'delete\' command with given range' do
            socket.should_receive(:puts).with('delete 5:10')
            socket.stub(:gets).and_return("OK\n")

            client.delete(5..10)
          end
        end

        context 'when position or range is nil' do
          it 'raises a CommandError' do
            socket.stub(:puts).with('delete')
            socket.stub(:gets).and_return("ACK [2@0] {delete} wrong number of arguments for \"delete\"\n")
            expect { client.delete(nil) }.to raise_error(CommandError, /ACK \[2@0\] \{delete\}/)
          end
        end
      end

      describe '#delete_id' do
        it_behaves_like 'a simple command', :delete_id, 'deleteid 10', 10
      end

      describe '#move' do
        context 'with position as from argument' do
          it 'sends a \'move\' command with given position' do
            socket.should_receive(:puts).with('move 2 10')
            socket.stub(:gets).and_return("OK\n")

            client.move(2, 10)
          end
        end

        context 'with range as from argument' do
          it 'sends a \'move\' command with given range as from argument' do
            socket.should_receive(:puts).with('move 1:2 3')
            socket.stub(:gets).and_return("OK\n")

            client.move(1..2, 3)
          end
        end
      end

      describe '#move_id' do
        it_behaves_like 'a simple command', :move_id, 'moveid 2 10', 2, 10
      end

      describe '#playlist_info' do

        let :response do
          [
            [
              "file: 2009-False Hopes Xv (V0)/01 - We're Workin' Hard.mp3\n",
              "Last-Modified: 2012-10-25T20:48:50Z\n",
              "Time: 52\n",
              "Artist: Doomtree\n",
              "AlbumArtist: Doomtree\n",
              "Title: We're Workin' Hard\n",
              "Album: F H : X V (False Hopes 15)\n",
              "Track: 1/8\n",
              "Date: 2009\n",
              "Genre: Hip Hop\n",
              "Disc: 1/1\n",
              "Pos: 0\n",
              "Id: 18\n"
            ],
            [
              "file: 2009-False Hopes Xv (V0)/05 - Scuffle - Dessa.mp3\n",
              "Last-Modified: 2012-10-25T20:48:52Z\n",
              "Time: 168\n",
              "Artist: Doomtree\n",
              "AlbumArtist: Doomtree\n",
              "Title: Scuffle ~ Dessa\n",
              "Album: F H : X V (False Hopes 15)\n",
              "Track: 5/8\n",
              "Date: 2009\n",
              "Genre: Hip Hop\n",
              "Disc: 1/1\n",
              "Pos: 1\n",
              "Id: 22\n",
              "OK\n"
            ]
          ]
        end

        context 'without optional position or range' do
          it 'sends a \'playlistinfo\' command' do
            socket.should_receive(:puts).with('playlistinfo')
            socket.stub(:gets).and_return(*response.flatten)

            client.playlist_info
          end

          it 'returns a list of hashes' do
            socket.stub(:puts).with('playlistinfo')
            socket.stub(:gets).and_return(*response.flatten)

            info = client.playlist_info
            info.should have(2).items
            info.collect { |r| r[:file] }.should == ["2009-False Hopes Xv (V0)/01 - We're Workin' Hard.mp3", "2009-False Hopes Xv (V0)/05 - Scuffle - Dessa.mp3"]
          end
        end

        context 'with position' do
          it 'sends a \'playlistinfo\' command with position' do
            socket.should_receive(:puts).with('playlistinfo 2')
            socket.stub(:gets).and_return(*response.last)

            client.playlist_info(2)
          end

          it 'returns a list containing one hash' do
            socket.stub(:puts).with('playlistinfo 2')
            socket.stub(:gets).and_return(*response.last)

            info = client.playlist_info(2)
            info.should have(1).items
            info.first[:file].should == '2009-False Hopes Xv (V0)/05 - Scuffle - Dessa.mp3'
          end
        end

        context 'with range' do
          it 'sends a \'playlistinfo\' command with position' do
            socket.should_receive(:puts).with('playlistinfo 2:4')
            socket.stub(:gets).and_return(*response.flatten)

            client.playlist_info(2..4)
          end
        end
      end
    end

    context 'Playback options' do
      describe '#consume' do
        context 'when given true' do
          it_behaves_like 'a simple command', :consume, 'consume 1', true
        end

        context 'when given false' do
          it_behaves_like 'a simple command', :consume, 'consume 0', false
        end
      end
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
            volume: 100,
            repeat: false,
            random: false,
            single: false,
            consume: false,
            playlist: 3,
            playlistlength: 1,
            xfade: false,
            mixrampdb: 0.000000,
            mixrampdelay: Float::NAN,
            state: :stop,
            song: 0,
            songid: 0
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
            :artists => 23,
            :albums => 27,
            :songs => 270,
            :uptime => 4560,
            :playtime => 66,
            :db_playtime => 77570,
            :db_update => 1371762307
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
          song[:track].should == 19
          song[:genre].should == 'Hip-Hop'
          song[:pos].should == 0
          song[:id].should == 0
          song[:time].should == 186
          song[:file].should == "19-gang_starr-next_time-dsp_int.mp3"
          song[:last_modified].should == "2011-06-22T22:23:56Z"
        end
      end
    end
  end
end
