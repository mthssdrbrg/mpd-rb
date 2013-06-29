# encoding: utf-8

shared_context 'client setup' do
  let :client do
    MPD::Client.new(socket)
  end

  let :socket do
    mock(:socket)
  end
end

shared_examples 'a simple command' do |command, expected, *args|
  include_context 'client setup'

  before do
    socket.stub(:puts).with(expected)
    socket.stub(:gets).and_return("OK\n")
  end

  it "sends a '#{command}' command to socket" do
    socket.should_receive(:puts).once
    client.send(command, *args)
  end

  context 'on successful command' do
    it 'returns :ok' do
      client.send(command, *args).should == :ok
    end
  end

  context 'on erroneous command' do
    it 'raises a CommandError' do
      socket.stub(:gets).and_return("ACK [50@0] {#{command}} error message")
      expect { client.send(command, *args) }.to raise_error(MPD::CommandError, /error message/)
    end
  end
end
