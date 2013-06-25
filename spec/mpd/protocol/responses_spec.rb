require 'spec_helper'

module MPD
  module Protocol
    shared_examples 'error handling' do
      context 'erroneous response' do
        ERROR_MAPPINGS.each do |code, error_constant|
          context "when error response code is #{code}" do
            it "returns a CommandError" do
              response = described_class.new(["ACK [#{code}@0] {command} error message"])
              exception = response.body
              exception.should be_a(CommandError)
              exception.code.should == code
              exception.index.should == 0
              exception.command.should == :command
              exception.message.should == 'error message'
            end
          end
        end
      end
    end

    describe Response do
      describe '#successful?' do
        it 'returns true if raw response is an empty list' do
          response = Response.new([])
          response.successful?.should be_true
        end

        it 'returns false if raw response is nil' do
          response = Response.new(nil)
          response.successful?.should be_false
        end

        it 'is aliased to #success?' do
          response = Response.new([])
          response.successful?.should be_true
          response.successful?.should == response.success?
        end
      end

      describe '#failure?' do
        it 'returns true if raw response contains an error line' do
          response = Response.new(['ACK [50@0] {command} error message'])
          response.failure?.should be_true
        end

        it 'returns true if raw response is nil' do
          response = Response.new(nil)
          response.failure?.should be_true
        end

        it 'is aliased to #error?' do
          response = Response.new(['ACK [50@0] {command} error message'])
          response.failure?.should be_true
          response.failure?.should == response.error?
        end
      end

      describe '#body' do
        context 'successful response' do
          it 'returns :ok' do
            response = Response.new([])
            response.body.should == :ok
          end
        end

        include_examples 'error handling'
      end
    end

    describe HashResponse do

      let :raw do
        [
          "file: 19-gang_starr-next_time-dsp_int.mp3",
          "Last-Modified: 2011-06-22T22:23:56Z",
          "Time: 186",
          "Artist: Gang Starr",
          "Title: Next Time",
          "Album: Moment Of Truth",
          "Track: 19",
          "Date: 1998",
          "Genre: Hip-Hop",
          "Pos: 0",
          "Id: 0"
        ]
      end

      describe '#body' do
        context 'successful response' do
          it 'makes a best effort to parse the response as a hash' do
            response = HashResponse.new(raw)
            response.body.should == {
              :file => '19-gang_starr-next_time-dsp_int.mp3',
              :last_modified => '2011-06-22T22:23:56Z',
              :time => '186',
              :artist => 'Gang Starr',
              :title => 'Next Time',
              :album => 'Moment Of Truth',
              :track => '19',
              :date => '1998',
              :genre => 'Hip-Hop',
              :pos => '0',
              :id => '0'
            }
          end

          it 'returns nil if raw response is an empty list' do
            response = HashResponse.new([])
            response.body.should be_nil
          end
        end

        include_examples 'error handling'
      end
    end

    describe ListResponse do
      describe '#body' do
        context 'successful response' do
          let :raw do
            [
              "file: 2009-False Hopes Xv (V0)/01 - We're Workin' Hard.mp3\n",
              "Last-Modified: 2012-10-25T20:48:50Z\n",
              "Time: 52\n",
              "Artist: Doomtree\n",
              "AlbumArtist: Doomtree\n",
              "Title: We're Workin' Hard\n",
              "Album: F H : X V (False Hopes 15)\n",
              "Track: 1/8\n",
              "Date: 2009\n",
              "Genre: Hip Hop\n",
              "Disc: 1/1\n",
              "Pos: 0\n",
              "Id: 18\n",
              "file: 2009-False Hopes Xv (V0)/05 - Scuffle - Dessa.mp3\n",
              "Last-Modified: 2012-10-25T20:48:52Z\n",
              "Time: 168\n",
              "Artist: Doomtree\n",
              "AlbumArtist: Doomtree\n",
              "Title: Scuffle ~ Dessa\n",
              "Album: F H : X V (False Hopes 15)\n",
              "Track: 5/8\n",
              "Date: 2009\n",
              "Genre: Hip Hop\n",
              "Disc: 1/1\n",
              "Pos: 1\n",
              "Id: 22\n"
            ]
          end

          it 'returns a list of hashes extracted from the raw response' do
            response = ListResponse.new(raw).body
            response.should have(2).items
            response.collect { |r| r[:id] }.should == ['18', '22']
          end

          it 'returns an empty list if raw response is empty' do
            response = ListResponse.new([])
            response.body.should == []
          end
        end

        include_examples 'error handling'
      end
    end
  end
end
