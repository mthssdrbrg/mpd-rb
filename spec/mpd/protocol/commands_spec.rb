require 'spec_helper'

module MPD
  module Protocol
    describe Command do

      let :transposer do
        MpdesqueTransposer.new
      end

      describe '#to_s' do
        it 'returns a string representation of a command' do
          command = Command.new(:next, transposer)
          command.to_s.should == 'next'
        end

        it 'removes underscore from command' do
          command = Command.new(:current_song, transposer)
          command.to_s.should == 'currentsong'
        end

        it 'translates booleans to integers' do
          command = Command.new(:consume, transposer, true)
          command.to_s.should == 'consume 1'

          command = Command.new(:consume, transposer, false)
          command.to_s.should == 'consume 0'
        end

        it 'translates ranges' do
          command = Command.new(:move, transposer, 1..5)
          command.to_s.should == 'move 1:5'

          command = Command.new(:move, transposer, 1...5)
          command.to_s.should == 'move 1:4'
        end

        context 'with multiple arguments' do
          it 'includes all arguments' do
            command = Command.new(:add_id, transposer, 'something-random.mp3', 10)
            command.to_s.should == 'addid something-random.mp3 10'
          end

          it 'ignores nil values' do
            command = Command.new(:cmd, transposer, 'something.mp3', nil, 10, nil)
            command.to_s.should == 'cmd something.mp3 10'

            command = Command.new(:cmd, transposer, nil, nil)
            command.to_s.should == 'cmd'
          end
        end
      end
    end
  end
end
