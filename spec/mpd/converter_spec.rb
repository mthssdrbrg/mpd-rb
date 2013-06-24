require 'spec_helper'
require 'tempfile'

module MPD
  describe Converter do
    let :converter do
      described_class.new do |c|
        c.transform(:boolean) { |value| value && value.to_i > 0 }
        c.transform(:float)   { |value| value == 'nan' ? Float::NAN : Float(value) }
        c.transform(:symbol)  { |value| value && value.to_sym }

        c.conversion :repeat, :random, :consume, :single, :xfade, :to => :boolean
        c.conversion :mixrampdelay, :to => :float
        c.conversion :state, :to => :symbol
        c.ignore :title, :artist, :album_artist
      end
    end

    describe '.load' do
      before do
        Tempfile.open('spec_conversions.rb') do |file|
          file.puts "transform(:symbol)  { |value| value && value.to_sym }"
          file.puts "conversion :state, :to => :symbol"
          @file = file.path
        end
      end

      let :converter do
        Converter.load(@file)
      end

      it 'loads conversion definitions from file' do
        converter.convert({state: 'play'}).should == {state: :play}
      end
    end

    describe '#convert' do
      it 'uses defined transformations' do
        converter.convert({state: 'play'}).should == {state: :play}
        converter.convert({state: 'stop'}).should == {state: :stop}
        converter.convert({mixrampdelay: '1.0'}).should == {mixrampdelay: 1.0}
        converter.convert({mixrampdelay: 'nan'}).should == {mixrampdelay: Float::NAN}
      end

      it 'respects ignore list' do
        converter.convert({title: '3'}).should == {title: '3'}
      end

      it 'converts strings that look like integers' do
        converter.convert({mixrampdb: '10'}).should == {mixrampdb: 10}
      end
    end
  end
end
