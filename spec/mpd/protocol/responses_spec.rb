require 'spec_helper'

module MPD
  module Protocol
    describe Response do
      let :response do
        Response.new(raw)
      end

      describe '#successful?' do
        context 'when raw response is an empty list' do
          let(:raw) { [] }

          it 'returns true' do
            response.successful?.should be_true
          end
        end

        context 'when raw response is nil' do
          let(:raw) { nil }

          it 'returns false' do
            response.successful?.should be_false
          end
        end

        it 'is aliased to #success?' do
          response = Response.new([])
          response.successful?.should be_true
          response.successful?.should == response.success?
        end
      end

      describe '#failure?' do
        context 'when raw response contains an error line' do
          let(:raw) { ['ACK [50@0] {command} error message'] }

          it 'returns true if raw response contains an error line' do
            response.failure?.should be_true
          end
        end

        context 'when raw response is nil' do
          let(:raw) { nil }

          it 'returns true if raw response is nil' do
            response.failure?.should be_true
          end
        end

        it 'is aliased to #error?' do
          response = Response.new(['ACK [50@0] {command} error message'])
          response.failure?.should be_true
          response.failure?.should == response.error?
        end
      end

      describe '#body' do
        context 'successful response' do
          let(:raw) { [] }

          it 'returns :ok' do
            response.body.should == :ok
          end
        end

        context 'erroneous response' do
          let(:raw) { ["ACK [51@0] {command} error message"] }

          it 'returns a CommandError' do
            response.body.should be_a(CommandError)
          end
        end
      end

      describe '#error' do
        context 'successful response' do
          let(:raw) { [] }

          it 'returns nil' do
            response.error.should be_nil
          end
        end

        context 'erroneous response' do
          let(:raw) { ["ACK [51@0] {command} error message"] }

          it 'returns a CommandError' do
            response.error.should be_a(CommandError)
          end
        end
      end
    end

    describe HashResponse do
      let :response do
        described_class.new(raw)
      end

      describe '#body' do
        context 'successful response' do
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

          it 'returns as hash representation of the response' do
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

          context 'when raw response is an empty list' do
            let(:raw) { [] }

            it 'returns nil if raw response is an empty list' do
              response.body.should be_nil
            end
          end
        end

        context 'erroneous response' do
          let(:raw) { ["ACK [51@0] {command} error message"] }

          it 'returns a CommandError' do
            response.body.should be_a(CommandError)
          end
        end
      end
    end

    describe SingleValueResponse do
      let :response do
        described_class.new(raw)
      end

      describe '#body' do
        context 'successful response' do
          let :raw do
            ["id: 12"]
          end

          it 'returns a single value' do
            response.body.should == '12'
          end

          context 'when raw response is an empty list' do
            let(:raw) { [] }

            it 'returns nil if raw response is an empty list' do
              response.body.should be_nil
            end
          end
        end

        context 'erroneous response' do
          let(:raw) { ["ACK [51@0] {command} error message"] }

          it 'returns a CommandError' do
            response.body.should be_a(CommandError)
          end
        end
      end
    end

    describe ListResponse do
      let :response do
        described_class.new(raw)
      end

      describe '#body' do
        context 'successful response' do
          context 'when raw response is empty' do
            let(:raw) { [] }

            it 'returns an empty list' do
              response.body.should == []
            end
          end

          context 'where each item is a single key-value pair' do
            context 'a single entry' do
              let :raw do
                ["file: 2009-False Hopes Xv (V0)/01 - We're Workin' Hard.mp3\n"]
              end

              it 'returns a list with a single hash' do
                list = response.body
                list.should have(1).item
                list.first.keys.should == [:file]
              end
            end

            context 'multiple entries' do
              let :raw do
                [
                  "file: 2009-False Hopes Xv (V0)/01 - We're Workin' Hard.mp3\n",
                  "file: 2009-False Hopes Xv (V0)/01 - We're Workin' Hard.mp3\n",
                  "file: 2009-False Hopes Xv (V0)/01 - We're Workin' Hard.mp3\n"
                ]
              end

              it 'returns a list of hashes' do
                list = response.body
                list.should have(3).items
                list.each { |i| i.keys.should == [:file] }
              end
            end
          end

          context 'where each item consists of multiple key-value pairs' do
            context 'a single entry' do
              let :raw do
                [
                  "file: 2009-False Hopes Xv (V0)/01 - We're Workin' Hard.mp3\n",
                  "Id: 18\n"
                ]
              end

              it 'returns a list with a single hash' do
                list = response.body
                list.should have(1).item
                list.each { |i| i.keys.should == [:file, :id] }
              end
            end

            context 'multiple entries' do
              let :raw do
                [
                  "file: 2009-False Hopes Xv (V0)/01 - We're Workin' Hard.mp3\n",
                  "Id: 18\n",
                  "file: 2009-False Hopes Xv (V0)/05 - Scuffle - Dessa.mp3\n",
                  "Id: 22\n"
                ]
              end

              it 'returns a list of hashes' do
                list = response.body
                list.should have(2).items
                list.each { |i| i.keys.should == [:file, :id] }
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

            it 'uses :file as a separator' do
              list = response.body
              list.should have(2).items
              list.each { |i| i.keys.should == [:file, :id] }
            end
          end

          context 'when given explicit delimiter' do
            let :raw do
              [
                "marker: marker1\n", "key2: bye\n", "key1: hi1\n",
                "marker: marker2\n", "key2: bye2\n", "key1: hi2\n"
              ]
            end

            let :response do
              ListResponse.new(raw, :delimiter => :marker)
            end

            it 'uses delimiter as separator' do
              list = response.body
              list.should have(2).items
              list.each { |r| r.keys.should == [:marker, :key2, :key1] }
            end
          end
        end

        context 'erroneous response' do
          let :raw do
            ["ACK [51@0] {command} error message"]
          end

          it 'returns a CommandError' do
            response.body.should be_a(CommandError)
          end
        end
      end
    end

    describe GroupedResponse do
      describe '#body' do
        context 'successful response' do
          let :raw do
            [
              'directory: directory 1',
              'file: file 1',
              'title: title 1',
              'file: file 2',
              'title: title 2',
              'directory: directory 2',
              'file: file 3',
              'directory: directory 3'
            ]
          end

          it 'groups items by given key' do
            response = described_class.new(raw, :group_by => :directory, :delimiter => :file)
            response.body.should == {
              'directory 1' => [{file: 'file 1', title: 'title 1'}, {file: 'file 2', title: 'title 2'}],
              'directory 2' => [{file: 'file 3'}],
              'directory 3' => []
            }
          end

          context 'items without any preceding top-level key' do
            let :raw do
              [
                'file: file 1',
                'title: title 1',
                'directory: directory 1',
                'file: file 2',
                'title: title 2',
              ]
            end

            it 'groups them under \'\'' do
              response = described_class.new(raw, :group_by => :directory, :delimiter => :file)
              response.body.should == {
                '' => [{file: 'file 1', title: 'title 1'}],
                'directory 1' => [{file: 'file 2', title: 'title 2'}]
              }
            end
          end
        end
      end
    end
  end
end
