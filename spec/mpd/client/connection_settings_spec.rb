# encoding: utf-8

require 'spec_helper'
require 'mpd/client/client_shared'

module MPD
  describe Client do
    include_context 'client setup'

    before do
      client.connect
    end

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

      context 'on erroneous command' do
        it 'raises a CommandError' do
          socket.stub(:gets).and_return("ACK [50@0] {close} error message")
          expect { client.close }.to raise_error(MPD::CommandError, /error message/)
        end
      end
    end
  end
end
