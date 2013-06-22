require 'spec_helper'
require 'socket'

# module MPD
#   class Client
#     attr_reader :host, :port

#     def initialize(options = {})
#       @host = options[:host] || 'localhost'
#       @port = options[:port] || 6600
#       @socket_factory = options[:socket_factory] || TCPSocket
#     end

#     def connect
#       @socket = @socket_factory.new(@host, @port)
#       @socket.gets
#       self
#     end

#     def stats
#       response = request('stats')
#       parsed = parse_response(response)
#       parsed.each { |k, v| parsed[k] = v.to_i }
#       parsed
#     end

#     def status
#       response = request('status')
#       parsed = parse_response(response)
#       parsed.each do |key, value|
#         parsed[key] = (key.eql?(:state) ? value : value.to_i)
#       end
#       parsed
#     end

#     private

#     OK = 'OK'.freeze

#     def request(command)
#       @socket.puts(command)
#       response = []

#       until (part = @socket.gets.strip!) == OK
#         response << part
#       end

#       response
#     end

#     def parse_response(list)
#       list.each_with_object({}) do |part, memo|
#         key, value = part.split(':')
#         memo[key.strip.to_sym] = value.strip
#       end
#     end
#   end

#   describe Client do

#     let :socket_factory do
#       mock(:socket_factory)
#     end

#     let :socket do
#       mock(:socket)
#     end

#     describe '#new' do
#       it 'accepts explicit host and port' do
#         client = MPD::Client.new(:host => 'some.client.local', :port => 3131)
#         client.host.should == 'some.client.local'
#         client.port.should == 3131
#       end

#       it 'defaults to MPD:s default settings' do
#         client = MPD::Client.new
#         client.host.should == 'localhost'
#         client.port.should == 6600
#       end
#     end

#     describe '#connect' do
#       before do
#         socket_factory.stub(:new).and_return(socket)
#         socket.stub(:gets).and_return('OK MPD 0.15.0')
#       end

#       it 'creates a new socket using the supplied factory' do
#         socket_factory.should_receive(:new).with('localhost', 6600)
#         client = MPD::Client.new(:socket_factory => socket_factory)
#         client.connect
#       end

#       it 'defaults to using TCPSocket' do
#         TCPSocket.should_receive(:new).with('localhost', 6600).and_return(socket)

#         client = MPD::Client.new
#         client.connect
#       end

#       it 'returns itself' do
#         client = MPD::Client.new(:socket_factory => socket_factory)
#         client.connect.should == client
#       end

#       it 'consumes initial OK message from server' do
#         socket.should_receive(:gets).and_return('OK MPD 0.15.0')

#         client = MPD::Client.new(:socket_factory => socket_factory)
#         client.connect
#       end

#       it 'raises error if unknow response from server'
#     end

#     context 'query commands' do
#       describe '#stats' do
#         let :client do
#           MPD::Client.new(:socket_factory => socket_factory)
#         end

#         before do
#           socket_factory.stub(:new).and_return(socket)
#           socket.stub(:gets)
#           client.connect
#         end

#         it 'sends correct request to the connected server' do
#           socket.should_receive(:puts).with('stats')
#           socket.stub(:gets).and_return("OK\n")
#           client.stats
#         end

#         it 'parses returned response from server' do
#           socket.should_receive(:puts).with('stats')
#           ["artists: 12\n", "songs: 534\n", "uptime: 600\n", "db_playtime: 2869\n", "db_update: 1371410005\n", "playtime: 345\n", "OK\n"].each do |line|
#             socket.should_receive(:gets).and_return(line)
#           end

#           client.stats.should == {
#             :artists => 12,
#             :songs => 534,
#             :uptime => 600,
#             :db_playtime => 2869,
#             :db_update => 1371410005,
#             :playtime => 345
#           }
#         end
#       end

#       describe '#status' do
#         let :client do
#           MPD::Client.new(:socket_factory => socket_factory)
#         end

#         before do
#           socket_factory.stub(:new).and_return(socket)
#           socket.stub(:gets)
#           client.connect
#         end

#         it 'sends correct request to the connected server' do
#           socket.should_receive(:puts).with('status')
#           socket.stub(:gets).and_return("OK\n")
#           client.status
#         end

#         it 'parses returned response from server' do
#           socket.should_receive(:puts).with('status')
#           [
#             "volume: 98\n",
#             "repeat: 0\n",
#             "random: 1\n",
#             "single: 0\n",
#             "consume: 1\n",
#             "playlist: 2\n",
#             "playlistlength: 12\n",
#             "state: play\n",
#             "song: 2\n",
#             "songid: 126\n",
#             "nextsong: 3\n",
#             "nextsongid: 127\n",
#             "time: 40\n",
#             "elapsed: 40\n",
#             "OK\n"
#           ].each do |line|
#             socket.should_receive(:gets).and_return(line)
#           end

#           client.status.should == {
#             :volume => 98,
#             :repeat => 0,
#             :random => 1,
#             :single => 0,
#             :consume => 1,
#             :playlist => 2,
#             :playlistlength => 12,
#             :state => 'play',
#             :song => 2,
#             :songid => 126,
#             :nextsong => 3,
#             :nextsongid => 127,
#             :time => 40,
#             :elapsed => 40
#           }
#         end
#       end
#     end

#     context 'playback options' do
#       let :client do
#         MPD::Client.new(:socket_factory => socket_factory)
#       end

#       before do
#         socket_factory.stub(:new).and_return(socket)
#         socket.stub(:gets)
#         client.connect
#       end
#     end
#   end
# end
