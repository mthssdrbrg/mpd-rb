# encoding: utf-8
require 'spec_helper'

module MPD
  describe Client do
    shared_context 'client setup' do
      let :client do
        MPD::Client.new(connection: connection)
      end

      let :connection do
        double(:connection, execute: [], connect: nil)
      end
    end

    describe '#connect' do
      include_context 'client setup'

      before do
        connection.stub(:connected?).and_return(false)
      end

      context 'when not given any host or port' do
        it 'tells connection to connect to localhost:6600' do
          client = described_class.new(connection: connection)
          client.connect
          expect(connection).to have_received(:connect).with('localhost', 6600)
        end
      end

      context 'when given explicit host and port' do
        it 'tells connection to connect to given host:port' do
          client = described_class.new(host: 'example.com', port: 4567, connection: connection)
          client.connect
          expect(connection).to have_received(:connect).with('example.com', 4567)
        end
      end

      context 'when already connected' do
        it 'does not attempt to connect again' do
          client = described_class.new(connection: connection)
          client.connect
          connection.stub(:connected?).and_return(true)
          client.connect

          expect(connection).to have_received(:connect).once
        end
      end
    end

    describe '#disconnect' do
      include_context 'client setup'

      before do
        connection.stub(:close)
      end

      context 'when connected' do
        before do
          connection.stub(:connected?).and_return(true)
          client.connect
        end

        it 'sends \'close\' command' do
          client.disconnect
          expect(connection).to have_received(:execute).with(Protocol::Command.new(:close))
        end

        it 'closes connection' do
          client.disconnect
          expect(connection).to have_received(:close)
        end
      end

      context 'when not connected' do
        it 'does nothing' do
          connection.should_receive(:connected?).and_return(false)

          client.disconnect

          expect(connection).to_not have_received(:execute)
          expect(connection).to_not have_received(:close)
        end
      end
    end
  end
end
