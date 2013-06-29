# encoding: utf-8

require 'spec_helper'
require 'mpd/client/client_shared'

module MPD
  describe Client do
    context 'Controlling playback' do
      describe '#next' do
        it_behaves_like 'a simple command', :next, 'next'
      end

      describe '#previous' do
        it_behaves_like 'a simple command', :previous, 'previous'
      end

      describe '#stop' do
        it_behaves_like 'a simple command', :stop, 'stop'
      end

      describe '#pause' do
        context 'when given true' do
          it_behaves_like 'a simple command', :pause, 'pause 1', true
        end

        context 'when given false' do
          it_behaves_like 'a simple command', :pause, 'pause 0', false
        end
      end

      describe '#play_id' do
        it_behaves_like 'a simple command', :play_id, 'playid 123', 123
      end

      describe '#play' do
        it_behaves_like 'a simple command', :play, 'play 123', 123
      end

      describe '#seek' do
        it_behaves_like 'a simple command', :seek, 'seek 3 120', 3, 120
      end

      describe '#seekid' do
        it_behaves_like 'a simple command', :seek_id, 'seekid 13 120', 13, 120
      end

      describe '#seekcur' do
        it_behaves_like 'a simple command', :seek_current, 'seekcur 120', 120
      end
    end
  end
end
