# encoding: utf-8

shared_context 'client setup' do
  let :client do
    MPD::Client.new(connection: connection)
  end

  let :connection do
    double(:connection, execute: [], connect: nil)
  end
end

shared_examples 'a command' do |command, expected, *args|
  include_context 'client setup'

  it "sends a '#{command}' command to the connection" do
    connection.should_receive(:execute).with(expected)
    client.send(command, *args)
  end

  it 'returns a Response' do
    response = client.send(command, *args)
    response.should be_a(MPD::Protocol::Response)
  end
end
