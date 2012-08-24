require 'spec_helper'

describe IO do 

	let(:io) do
		Class.new do
			extend MPD::IO
		end
	end

	before(:each) do
    @mocked_socket = mock(TCPSocket)
    TCPSocket.stub!(:new).and_return(@mocked_socket)
  end

	context 'default methods' do

		it 'should have a socket, host and port' do
			[:socket, :host, :port].each do |m|
				io.should respond_to(m)
			end
		end

    it "raises an exception if no host and port is specified" do
      expect { io.connect }.to raise_error(ArgumentError)
    end

    it "should remember the port and host on connect" do
      io.connect('localhost', 6601)
      io.host.should eql('localhost')
      io.port.should eql(6601)
    end

    it "should write to a socket" do
    	io.connect('localhost', 6601)
      data = "status\n"
      @mocked_socket.should_receive(:write).with(data).and_return(data.length)
      io.write(data).should eql(data.length)
    end

    it "should read from a socket" do
    	io.connect('localhost', 6601)
      @mocked_socket.should_receive(:gets).and_return("response\n")
      response = io.read
      response.should eq("response\n")
    end

	end
end
