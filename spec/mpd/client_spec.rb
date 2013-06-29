# encoding: utf-8
require 'spec_helper'
require 'mpd/client/client_shared'

module MPD
  describe Client do
    describe '.command' do
      pending
    end

    describe '#connect' do
      include_context 'client setup'

      it 'defaults to localhost:6600' do
        socket_class.should_receive(:new).with('localhost', 6600).and_return(socket)
        client = MPD::Client.new(socket_class: socket_class)
        client.connect
      end

      it 'uses explicit host and port' do
        socket_class.should_receive(:new).with('example.com', 4567).and_return(socket)
        client = MPD::Client.new(host: 'example.com', port: 4567, socket_class: socket_class)
        client.connect
      end

      it 'performs initial handshake' do
        socket.should_receive(:gets).and_return("OK MPD 0.17.0\n")
        client.connect
      end

      it 'sets protocol version' do
        client.connect
        client.protocol_version.should == '0.17.0'
      end

      it 'returns self' do
        client.connect.should == client
      end

      it 'connects once' do
        socket_class.should_receive(:new).with('localhost', 6600).once
        client.connect
        client.connect
      end
    end

    describe '#disconnect' do
      include_context 'client setup'

      before do
        socket.stub(:puts).with('close')
        socket.stub(:closed?).and_return(false)
        socket.stub(:close)
      end

      it 'sends \'close\' command to socket' do
        client.connect

        socket.should_receive(:puts).with('close')
        socket.stub(:gets)

        client.disconnect
      end

      it 'closes the socket' do
        client.connect

        socket.should_receive(:close)
        client.disconnect
      end

      it 'does nothing if not connected' do
        socket.should_not_receive(:close)
        socket.should_not_receive(:puts)
        socket.should_not_receive(:gets)

        client.disconnect
      end
    end
  end
end
