require 'spec_helper'

describe MPD do

	let(:mpd) { MPD.new }

	context 'when initialized' do

		it 'should set default host and port if not specified' do
			mpd.host.should eq('localhost')
			mpd.port.should eq(6600)
		end

	end

	context 'requests' do

		it 'should respond to different requests' do
			mpd.should respond_to(:status)
			mpd.should respond_to(:stats)
		end

	end

end
