# encoding: utf-8

require 'spec_helper'
require 'mpd/client/client_shared'

module MPD
  describe Client do
    include_context 'client setup'

    before do
      client.connect
    end

    context 'The music database' do
      context '#update' do
        before do
          socket.stub(:puts)
          socket.stub(:gets).and_return("updating_db: 4\n", "OK\n")
        end

        context 'when given an URI' do

          let :uri do
            'this has spaces/in on it.mp3'
          end

          it 'sends the \'update\' command with URI' do
            socket.should_receive(:puts).with("update \"#{uri}\"")

            client.update(uri)
          end

          it 'returns a hash with the job ID' do
            client.update(uri).should == {updating_db: '4'}
          end
        end

        context 'when not given any URI' do
          it 'sends the \'update\' command' do
            socket.should_receive(:puts).with('update')

            client.update
          end

          it 'returns a hash with the job ID' do
            client.update.should == {updating_db: '4'}
          end
        end
      end

      context '#rescan' do
        before do
          socket.stub(:puts)
          socket.stub(:gets).and_return("updating_db: 3\n", "OK\n")
        end

        context 'when given an URI' do

          let :uri do
            'this has spaces/in on it.mp3'
          end

          it 'sends the \'rescan\' command with URI' do
            socket.should_receive(:puts).with("rescan \"#{uri}\"")

            client.rescan(uri)
          end

          it 'returns a hash with the job ID' do
            client.rescan(uri).should == {updating_db: '3'}
          end
        end

        context 'when not given any URI' do
          it 'sends the \'rescan\' command' do
            socket.should_receive(:puts).with('rescan')

            client.rescan
          end

          it 'returns a hash with the job ID' do
            client.rescan.should == {updating_db: '3'}
          end
        end
      end

      context '#count' do
        context 'with valid arguments' do
          it 'returns a hash with statistics' do
            socket.stub(:puts).with('count artist "Spec Artist"')
            socket.stub(:gets).and_return("songs: 5\n", "playtime: 620\n", "OK\n")
            client.count(:artist, 'Spec Artist').should == {
              songs: '5',
              playtime: '620'
            }
          end
        end

        context 'with invalid arguments' do
          it 'raises CommandError' do
            socket.stub(:puts)
            socket.stub(:gets).and_return("ACK [2@0] {count} incorrect arguments\n")
            expect { client.count('something', 'wrong') }.to raise_error(CommandError, /incorrect arguments/)
          end
        end

        context 'with too few arguments' do
          it 'raises CommandError' do
            socket.stub(:puts)
            socket.stub(:gets).and_return("ACK [2@0] {count} too few arguments for \"count\"\n")
            expect { client.count('something') }.to raise_error(CommandError, /too few arguments/)
            expect { client.count }.to raise_error(CommandError, /too few arguments/)
          end
        end
      end

      context '#find' do
        before do
          socket.stub(:puts)
          socket.stub(:gets).and_return(*response)
        end

        context 'with valid arguments' do
          let :response do
            [
              "file: Archways - Det finns inget vackert kvar i romantik/Archways - Det finns inget vackert kvar i romantik - 01 Vinterhalva\xCC\x8Aren.flac\n",
              "Last-Modified: 2013-03-09T14:16:04Z\n",
              "Time: 73\n",
              "Title: Vinterhalv\xC3\xA5ren\n",
              "Artist: Archways\n",
              "Date: 2013\n",
              "Album: Det finns inget vackert kvar i romantik\n",
              "Track: 1\n",
              "file: Archways - Det finns inget vackert kvar i romantik/Archways - Det finns inget vackert kvar i romantik - 02 Det finns inget vackert kvar i romantik.flac\n",
              "Last-Modified: 2013-03-09T14:16:04Z\n",
              "Time: 93\n",
              "Title: Det finns inget vackert kvar i romantik\n",
              "Artist: Archways\n",
              "Date: 2013\n",
              "Album: Det finns inget vackert kvar i romantik\n",
              "Track: 2\n",
              "file: Archways - Det finns inget vackert kvar i romantik/Archways - Det finns inget vackert kvar i romantik - 03 Ikva\xCC\x88ll a\xCC\x88r du som do\xCC\x88d fo\xCC\x88r mig.flac\n",
              "Last-Modified: 2013-03-09T14:16:04Z\n",
              "Time: 139\n",
              "Title: Ikv\xC3\xA4ll \xC3\xA4r du som d\xC3\xB6d f\xC3\xB6r mig\n",
              "Artist: Archways\n",
              "Date: 2013\n",
              "Album: Det finns inget vackert kvar i romantik\n",
              "Track: 3\n",
              "file: Archways - Det finns inget vackert kvar i romantik/Archways - Det finns inget vackert kvar i romantik - 04 Livra\xCC\x88dd fo\xCC\x88r livet.flac\n",
              "Last-Modified: 2013-03-09T14:16:04Z\n",
              "Time: 150\n",
              "Title: Livr\xC3\xA4dd f\xC3\xB6r livet\n",
              "Artist: Archways\n",
              "Date: 2013\n",
              "Album: Det finns inget vackert kvar i romantik\n",
              "Track: 4\n",
              "file: Archways - Det finns inget vackert kvar i romantik/Archways - Det finns inget vackert kvar i romantik - 05 Farva\xCC\x88l.flac\n",
              "Last-Modified: 2013-03-09T14:16:04Z\n",
              "Time: 165\n",
              "Title: Farv\xC3\xA4l\n",
              "Artist: Archways\n",
              "Date: 2013\n",
              "Album: Det finns inget vackert kvar i romantik\n",
              "Track: 5\n",
              "OK\n"
            ]
          end

          it 'returns a list of hashes' do
            socket.stub(:puts).with('find any Archways')
            result = client.find(:any, 'Archways')
            result.should have(5).items
            result.each do
              |r| r.keys.should == [:file, :last_modified, :time, :title, :artist, :date, :album, :track]
            end
          end
        end

        context 'with invalid arguments' do
          let(:response) { "ACK [2@0] {find} incorrect arguments\n" }

          it 'raises CommandError' do
            expect { client.find(:any, 'wrong', 'things') }.to raise_error(CommandError, /incorrect arguments/)
            expect { client.find('not supported', 'wrong') }.to raise_error(CommandError, /incorrect arguments/)
          end
        end

        context 'with too few arguments' do
          let(:response) { "ACK [2@0] {find} too few arguments for \"find\"\n" }

          it 'raises CommandError' do
            expect { client.find('something') }.to raise_error(CommandError, /too few arguments/)
            expect { client.find }.to raise_error(CommandError, /too few arguments/)
          end
        end
      end

      context '#findadd' do
        context 'with valid arguments' do
          it_behaves_like 'a simple command', :find_add, 'findadd any "Bring Me The Horizon"', :any, 'Bring Me The Horizon'
        end

        context 'with invalid arguments' do
          before do
            socket.stub(:puts)
            socket.stub(:gets).and_return("ACK [2@0] {findadd} incorrect arguments\n")
          end

          it 'raises CommandError' do
            expect { client.find_add(:any, 'wrong', 'things') }.to raise_error(CommandError, /incorrect arguments/)
            expect { client.find_add('not supported', 'wrong') }.to raise_error(CommandError, /incorrect arguments/)
          end
        end

        context 'with too few arguments' do
          before do
            socket.stub(:puts)
            socket.stub(:gets).and_return("ACK [2@0] {findadd} too few arguments for \"findadd\"\n")
          end

          it 'raises CommandError' do
            expect { client.find_add('something') }.to raise_error(CommandError, /too few arguments/)
            expect { client.find_add }.to raise_error(CommandError, /too few arguments/)
          end
        end
      end

      context '#list' do
        before do
          socket.stub(:puts)
          socket.stub(:gets).and_return(*response)
        end

        context 'with valid arguments' do
          context 'without artist argument' do
            let :response do
              [
                "Album: Pure Fix Mix\n",
                "Album: Det finns inget vackert kvar i romantik\n",
                "Album: Whenever, If Ever\n",
                "Album: Yeezus\n",
                "Album: House of Dreams - Single\n",
                "Album: Know Hope\n",
                "Album: F H : X V (False Hopes 15)\n",
                "Album: \n",
                "Album: PeepCode Screencasts\n",
                "Album: The Wall (disc 1)\n",
                "Album: The Wall (disc 2)\n",
                "Album: The Future Is Cancelled\n",
                "Album: The Dark Side Of The Moon {Japanese vinyl}\n",
                "Album: if there is light, it will find you\n",
                "OK\n"
              ]
            end

            it 'returns a list of hashes' do
              socket.stub(:puts).with('list album')
              result = client.list(:album)
              result.should have(14).items
              result.each { |r| r.keys.should == [:album] }
            end
          end

          context 'with optional artist argument' do
            let(:response) do
              [
               "Album: Sempiternal\n",
               "OK\n"
              ]
            end

            it 'returns albums for given artist' do
              socket.stub(:puts).with('list album "Bring Me The Horizon"')
              result = client.list(:album, 'Bring Me The Horizon')
              result.should have(1).item
              result.first.should == {album: 'Sempiternal'}
            end
          end
        end

        context 'with invalid arguments' do
          let(:response) { "ACK [2@0] {list} \"something\" is not known\n" }

          it 'raises CommandError' do
            expect { client.list(:something) }.to raise_error(CommandError, /"something" is not known/)
          end
        end

        context 'with too few arguments' do
          let(:response) { "ACK [2@0] {list} too few arguments for \"list\"\n" }

          it 'raises CommandError' do
            expect { client.list }.to raise_error(CommandError, /too few arguments/)
          end
        end
      end
    end
  end
end
