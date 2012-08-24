require 'spec_helper'

class ProtocolTest
	include MPD::Protocol
end

module MPD

	describe Protocol do

#		let(:mocked_socket) { mock(TCPSocket) }
    let(:protocol) { ProtocolTest.new }

		before(:each) do
#	    TCPSocket.stub!(:new).and_return(mocked_socket) # don't use a real socket
      protocol.connect('localhost', 6600)
		end

    it 'should implement no auth' do
      protocol.auth.should be_true
    end
 
		describe 'requests' do

      before(:each) do
        protocol.auth
      end

      describe "querying MPD's status" do

        it 'should implement #status' do
          protocol.should respond_to(:status)

          # mocked_socket.should_receive(:write).with(kind_of(Protocol::Request)).and_return(6)
          # mocked_socket.should_receive(:gets)

          response = protocol.status
          response.should be_instance_of Protocol::Response
          response.payload.should be_kind_of(Hash)
        end

        it 'should implement #stats' do
          protocol.should respond_to(:stats)

          response = protocol.stats
          response.should be_instance_of Protocol::Response
          response.payload.should be_kind_of(Hash)
        end

        it 'should implement #clearerror' do
          protocol.should respond_to(:clearerror)

          response = protocol.clearerror
          response.should be_instance_of Protocol::Response
          response.payload.should be_kind_of(Hash)

          response.payload.should be_empty
        end

        it 'should implement #currentsong' do
          protocol.should respond_to(:currentsong)

          response = protocol.currentsong
          response.should be_instance_of Protocol::Response
          response.payload.should be_kind_of(Hash)
        end

      end
		end
	end
end
