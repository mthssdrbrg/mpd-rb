# encoding: utf-8
require 'spec_helper'
require 'socket'

module MPD
  module Io
    describe Connection do
      let :connection do
        described_class.new(socket_impl)
      end

      let :socket_impl do
        double(:socket_impl)
      end

      let :socket do
        double(:socket)
      end

      before do
        socket_impl.stub(:new).with('localhost', 6600).and_return(socket)
      end

      describe '#connect' do
        it 'creates a socket and performs initial handshake' do
          socket.should_receive(:gets).and_return("OK MPD 0.17.0\n")
          connection.connect('localhost', 6600)
        end

        it 'sets protocol version' do
          socket.stub(:gets).and_return("OK MPD 0.17.0\n")
          connection.connect('localhost', 6600)
          connection.version.should == '0.17.0'
        end

        it 'returns self' do
          socket.stub(:gets).and_return("OK MPD 0.17.0\n")
          connection.connect('localhost', 6600).should == connection
        end

        context 'when there is an existing socket' do
          before do
            socket.stub(:gets).and_return("OK MPD 0.17.0\n")
            socket.stub(:closed?).and_return(false)
          end

          it 'closes the existing socket and opens a new one' do
            socket.should_receive(:close).once
            socket_impl.should_receive(:new).twice

            2.times { connection.connect('localhost', 6600) }
          end

          it 'checks if existing socket is already closed' do
            socket.stub(:closed?).and_return(true)
            socket_impl.should_receive(:new).twice

            2.times { connection.connect('localhost', 6600) }
          end
        end
      end

      describe '#execute' do
        context 'given a command' do
          let :command do
            double(:command, to_s: 'this is a fake command')
          end

          before do
            socket.stub(:puts)
            socket.stub(:gets).and_return("OK MPD 0.17.0\n")
            socket.stub(:each_with_object)
            connection.connect('localhost', 6600)
          end

          it 'calls #to_s on it' do
            connection.execute(command)
            expect(command).to have_received(:to_s)
          end

          it 'sends it to socket' do
            connection.execute(command)
            expect(socket).to have_received(:puts).with('this is a fake command')
          end

          it 'raises NotConnectedError if not connected' do
            connection = described_class.new
            expect { connection.execute('something') }.to raise_error(NotConnectedError)
          end

          context 'reading response' do
            it 'reads until encountering OK footer' do
              socket.stub(:each_with_object) { |memo, &blk| ["a line\n", "another\n", "OK\n", "Past end\n"].each_with_object(memo, &blk) }
              response = connection.execute(command)
              response.should == ['a line', 'another']
            end

            it 'considers nil to be a footer' do
              socket.stub(:each_with_object) { |memo, &blk| ["a line\n", "another\n", nil, "Past end\n"].each_with_object(memo, &blk) }
              response = connection.execute(command)
              response.should == ['a line', 'another']
            end

            it 'reads until encountering an error footer' do
              socket.stub(:each_with_object) { |memo, &blk| ["a line\n", "another\n", "ACK [10@0] {error}\n", "Past end\n"].each_with_object(memo, &blk) }
              response = connection.execute(command)
              response.should == ['a line', 'another', 'ACK [10@0] {error}']
            end
          end
        end
      end
    end
  end
end
