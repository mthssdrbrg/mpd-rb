require 'spec_helper'

module MPD
  module Protocol
    describe RubyesqueTransposer do

      let :transposer do
        described_class.new
      end

      describe '#transpose_boolean' do
        it 'transposes integers to booleans' do
          transposer.transpose_boolean(1).should be_true
          transposer.transpose_boolean(2).should be_true
          transposer.transpose_boolean(0).should be_false
        end

        it 'tranposes integer strings to booleans' do
          transposer.transpose_boolean('1').should be_true
          transposer.transpose_boolean('2').should be_true
          transposer.transpose_boolean('0').should be_false
        end
      end

      describe '#transpose_float' do
        it 'transposes the string \'nan\' to Float::NAN' do
          transposer.transpose_float('nan').to_s.should == 'NaN' # trololol
        end

        it 'transposes a string containing a float' do
          transposer.transpose_float('3.14').should == 3.14
        end
      end

      describe '#transpose' do
        it 'transposes certain strings to booleans' do
          transposed = transposer.transpose({playlist: '3', repeat: '0', random: '1', single: '0', xfade: '0'})
          transposed.should == {
            playlist: 3,
            repeat: false,
            random: true,
            single: false,
            xfade: false
          }
        end

        it 'transposes certain strings to symbols' do
          transposer.transpose({state: 'play'}).should == {:state => :play}
        end

        it 'transposes mixrampdelay to Float::NAN' do
          transposer.transpose({mixrampdelay: 'nan'}).should == {mixrampdelay: Float::NAN}
        end

        it 'transposes strings to integers' do
          transposer.transpose({volume: '100', playlist: '3'}).should == {volume: 100, playlist: 3}
        end
      end
    end

    describe MpdesqueTransposer do
      let :transposer do
        described_class.new
      end

      describe '#transpose_range' do
        it 'transposes a Ruby Range to a \'MPD\' Range' do
          transposer.transpose_range(1..5).should == '1:5'
          transposer.transpose_range(1...5).should == '1:4'
        end
      end

      describe '#transpose_boolean' do
        it 'transposes true to 1' do
          transposer.transpose_boolean(true).should == '1'
        end

        it 'transposes false to 0' do
          transposer.transpose_boolean(false).should == '0'
        end
      end

      describe '#transpose' do
        it 'transposes ranges' do
          transposer.transpose(1..5).should == '1:5'
        end

        it 'transposes booleans' do
          transposer.transpose(true).should == '1'
        end

        it 'does not care about integers, and strings, and etc' do
          [1, '1'].each { |i| transposer.transpose(i).should == i }
        end
      end
    end
  end
end
