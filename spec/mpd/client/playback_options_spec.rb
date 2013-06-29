# encoding: utf-8

require 'spec_helper'
require 'mpd/client/client_shared'

module MPD
  describe Client do
    context 'Playback options' do
      describe '#consume' do
        context 'when given true' do
          it_behaves_like 'a simple command', :consume, 'consume 1', true
        end

        context 'when given false' do
          it_behaves_like 'a simple command', :consume, 'consume 0', false
        end
      end

      describe '#random' do
        context 'when given true' do
          it_behaves_like 'a simple command', :random, 'random 1', true
        end

        context 'when given false' do
          it_behaves_like 'a simple command', :random, 'random 0', false
        end
      end

      describe '#repeat' do
        context 'when given true' do
          it_behaves_like 'a simple command', :repeat, 'repeat 1', true
        end

        context 'when given false' do
          it_behaves_like 'a simple command', :repeat, 'repeat 0', false
        end
      end

      describe '#single' do
        context 'when given true' do
          it_behaves_like 'a simple command', :single, 'single 1', true
        end

        context 'when given false' do
          it_behaves_like 'a simple command', :single, 'single 0', false
        end
      end

      describe '#crossfade' do
        it_behaves_like 'a simple command', :crossfade, 'crossfade 3', 3
      end

      describe '#volume' do
        it_behaves_like 'a simple command', :volume, 'setvol 78', 78
      end

      describe '#mixramp_db' do
        it_behaves_like 'a simple command', :mixramp_db, 'mixrampdb -17', -17
      end

      describe '#mixramp_delay' do
        it_behaves_like 'a simple command', :mixramp_delay, 'mixrampdelay 2', 2
      end

      describe '#replay_gain_mode', pending: true do
        it_behaves_like 'a simple command', :replay_gain_mode, 'replay_gain_mode track', :track
      end

      describe '#replay_gain_status', pending: true do
        it_behaves_like 'a simple command', :replay_gain_status, 'replay_gain_status'
      end
    end
  end
end
