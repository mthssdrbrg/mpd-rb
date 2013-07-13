require 'spec_helper'

module MPD
  module Protocol
    describe Command do
      describe '#to_s' do
        it 'returns a string representation of a command' do
          command = Command.new(:next)
          command.to_s.should == 'next'
        end

        it 'removes underscore from command' do
          command = Command.new(:current_song)
          command.to_s.should == 'currentsong'
        end

        it 'translates booleans to integers' do
          command = Command.new(:consume, true)
          command.to_s.should == 'consume 1'

          command = Command.new(:consume, false)
          command.to_s.should == 'consume 0'
        end

        it 'translates ranges' do
          command = Command.new(:move, 1..5)
          command.to_s.should == 'move 1:5'

          command = Command.new(:move, 1...5)
          command.to_s.should == 'move 1:4'
        end

        it 'wraps arguments with whitespace in double quotes' do
          command = Command.new(:something, 'this has white    spaces')
          command.to_s.should == 'something "this has white    spaces"'
          command = Command.new(:something, "this has white\tspaces")
          command.to_s.should == "something \"this has white\tspaces\""
        end

        context 'with multiple arguments' do
          it 'includes all arguments' do
            command = Command.new(:add_id, 'something-random.mp3', 10)
            command.to_s.should == 'addid something-random.mp3 10'
          end

          it 'ignores nil values' do
            command = Command.new(:cmd, 'something.mp3', nil, 10, nil)
            command.to_s.should == 'cmd something.mp3 10'

            command = Command.new(:cmd, nil, nil)
            command.to_s.should == 'cmd'
          end
        end
      end

      describe '#eql?' do
        it 'returns true if command and arguments are the same' do
          c1 = Command.new(:seek, 10)
          c2 = Command.new(:seek, 10)
          c1.should eql(c2)
        end

        it 'makes a difference between strings and symbols' do
          c1 = Command.new(:seek, 10)
          c2 = Command.new('seek', 10)
          c1.should_not eql(c2)
        end

        it 'returns false if command is the same but arguments differ' do
          c1 = Command.new(:seek, 11)
          c2 = Command.new(:seek, 10)
          c1.should_not eql(c2)
        end

        it 'returns false if commands differ but arguments are the same' do
          c1 = Command.new(:forward, 10)
          c2 = Command.new(:seek, 10)
          c1.should_not eql(c2)
        end

        it 'is aliased as ==' do
          c1 = Command.new(:seek, 10)
          c2 = Command.new(:seek, 10)
          c1.should == c2
        end
      end
    end
  end
end
