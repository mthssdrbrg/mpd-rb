# encoding: utf-8

require 'spec_helper'
require 'mpd/client/client_shared'

module MPD
  describe Client do
    include_context 'client setup'

    before do
      client.connect
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
              client.add_id(file_uri, position).should == {:id => '12'}
            end
          end

          context 'without explicit position' do
            it 'sends an \'add_id\' without position to socket' do
              socket.should_receive(:puts).with("addid #{file_uri}")
              client.add_id(file_uri)
            end

            it 'returns a hash containing a single key-value pair' do
              client.add_id(file_uri).should == {:id => '12'}
            end
          end
        end

        context 'erroneous command' do
          it 'raises a CommandError' do
            socket.stub(:gets).and_return("ACK [50@0] {addid} Not found\n")
            expect { client.add_id(file_uri) }.to raise_error(CommandError, /Not found/)
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
            expect { client.delete(nil) }.to raise_error(CommandError, /wrong number of arguments for/)
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

      describe '#swap' do
        it_behaves_like 'a simple command', :swap, 'swap 2 3', 2, 3
      end

      describe '#swap_id' do
        it_behaves_like 'a simple command', :swap_id, 'swapid 2 3', 2, 3
      end

      describe '#shuffle' do
        context 'with range' do
          it_behaves_like 'a simple command', :shuffle, 'shuffle 0:5', 0..5
        end

        context 'without range' do
          it_behaves_like 'a simple command', :shuffle, 'shuffle'
        end
      end
    end
  end
end
