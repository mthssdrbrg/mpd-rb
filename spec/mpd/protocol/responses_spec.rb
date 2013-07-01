require 'spec_helper'

module MPD
  module Protocol
    shared_examples 'error handling' do
      context 'erroneous response' do
        ERROR_MAPPINGS.each do |code, error_constant|
          context "when error response code is #{code}" do
            it "returns a CommandError" do
              response = described_class.new(["ACK [#{code}@0] {command} error message"])
              exception = response.error
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

        context 'erroneous response' do
          it 'returns a CommandError' do
            response = described_class.new(["ACK [51@0] {command} error message"])
            response.body.should be_a(CommandError)
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

        context 'erroneous response' do
          it 'returns a CommandError' do
            response = described_class.new(["ACK [51@0] {command} error message"])
            response.body.should be_a(CommandError)
          end
        end

        include_examples 'error handling'
      end
    end

    describe ListResponse do
      describe '#body' do
        context 'successful response' do
          context 'when given explicit marker' do
            context 'multiple entries' do
              let :raw do
                [
                  "marker: marker1", "key2: bye", "key1: hi1",
                  "marker: marker2", "key2: bye2", "key1: hi2"
                ]
              end

              it 'returns a list of hashes, separated by marker' do
                response = ListResponse.new(raw, :marker => :marker).body
                response.should have(2).items
                response.collect { |r| r[:marker] }.should == ['marker1', 'marker2']
              end
            end

            context 'single entry' do
              let :raw do
                [
                  "marker: marker1", "key1: hi", "key2: bye"
                ]
              end

              it 'returns a list of hashes, separated by marker' do
                response = ListResponse.new(raw, :marker => :marker).body
                response.should have(1).items
                response.collect { |r| r[:marker] }.should == ['marker1']
              end
            end
          end

          context 'when not given explicit marker' do
            let :raw do
              [
                "file: 2009-False Hopes Xv (V0)/01 - We're Workin' Hard.mp3\n",
                "Id: 18\n",
                "file: 2009-False Hopes Xv (V0)/05 - Scuffle - Dessa.mp3\n",
                "Id: 22\n"
              ]
            end

            it 'returns a list of hashes, separated by :file' do
              response = ListResponse.new(raw).body
              response.should have(2).items
              response.collect { |r| r[:id] }.should == ['18', '22']
            end

            it 'returns an empty list if raw response is empty' do
              response = ListResponse.new([])
              response.body.should == []
            end
          end
        end

        context 'erroneous response' do
          it 'returns a CommandError' do
            response = described_class.new(["ACK [51@0] {command} error message"])
            response.body.should be_a(CommandError)
          end
        end

        include_examples 'error handling'
      end
    end
  end
end
