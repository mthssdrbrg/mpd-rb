# encoding: utf-8

require 'spec_helper'
require 'mpd/client/client_shared'

module MPD
  describe Client do
    include_context 'client setup'

    describe '#close' do
      before do
        client.connect

        socket.stub(:puts).with('close')
        socket.stub(:gets).and_return(nil)
      end

      it 'sends a \'close\' command' do
        socket.should_receive(:puts).once
        client.close
      end

      context 'on successful command' do
        it 'returns :ok' do
          client.close.should == :ok
        end
      end
    end

    describe '#kill' do
      before do
        client.connect

        socket.stub(:puts).with('kill')
        socket.stub(:gets).and_return(nil)
      end

      it 'sends a \'kill\' command' do
        socket.should_receive(:puts).once
        client.kill
      end

      context 'on successful command' do
        it 'returns :ok' do
          client.kill.should == :ok
        end
      end
    end

    describe '#ping' do
      it_behaves_like 'a simple command', :ping, 'ping'
    end
  end
end
