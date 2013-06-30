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
    end
  end
end
