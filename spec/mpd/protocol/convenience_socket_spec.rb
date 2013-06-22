require 'spec_helper'

module MPD
  module Protocol
    describe ConvenienceSocket do

      let :convenient_socket do
        described_class.new(tcp_socket)
      end

      let :tcp_socket do
        mock(:socket)
      end

      describe '#execute' do

        before do
          tcp_socket.stub(:puts).with('command')
          tcp_socket.stub(:gets).and_return("OK\n")
        end

        it 'sends given command to socket' do
          tcp_socket.should_receive(:puts).with('command')

          convenient_socket.execute('command')
        end

        it 'calls #to_s on given command' do
          tcp_socket.should_receive(:puts).with('command')

          convenient_socket.execute(:command)
        end

        context 'successful commands' do
          context 'responses that consists of a single \'OK\'' do
            it 'handles them' do
              tcp_socket.should_receive(:gets).once

              convenient_socket.execute('command')
            end

            it 'returns an empty list' do
              convenient_socket.execute('command').should be_empty
            end
          end

          context 'responses that consists of several lines' do

            before do
              tcp_socket.stub(:gets).and_return("first_line\n", "second_line\n", "third_line\n", "OK\n")
            end

            it 'handles them' do
              tcp_socket.should_receive(:gets).exactly(4).times

              convenient_socket.execute('command')
            end

            it 'returns a list containing the response' do
              convenient_socket.execute('command').should have(3).items
            end

            it 'strips trailing new line characters' do
              convenient_socket.execute('command').should == %w[first_line second_line third_line]
            end
          end
        end

        context 'erroneous commands' do
          it 'returns a list with a single item containing the error' do
            tcp_socket.stub(:gets).and_return("ACK [50@0] {command} error message")
            convenient_socket.execute('command').should == ['ACK [50@0] {command} error message']
          end
        end
      end
    end
  end
end
