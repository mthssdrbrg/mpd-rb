require 'spec_helper'

class Target < Struct.new(:connection)
  extend MPD::CommandDsl

  command :spec
  command :spec_with_raw_option, raw: :raw_spec

  [:hash, :single_value, :list, :grouped].each do |type|
    command "with_#{type}_response".to_sym, response: type
  end
end

module MPD
  describe CommandDsl do

    let :target do
      Target.new(connection)
    end

    let :connection do
      double(:connection, execute: [])
    end

    it 'creates a method with given name' do
      target.should respond_to(:spec)
    end

    it 'proxies any arguments to the created Command' do
      target.spec(1, 2, 3, 4, 5, 'hi', true)
      expect(connection).to have_received(:execute).with(Protocol::Command.new(:spec, 1, 2, 3, 4, 5, 'hi', true))
    end

    it 'returns a Response by default' do
      target.spec.should be_a(Protocol::Response)
    end

    context ':raw' do
      it 'uses the value of :raw as command symbol' do
        target.spec_with_raw_option
        expect(connection).to have_received(:execute).with(Protocol::Command.new(:raw_spec))
      end
    end

    context ':response' do
      context ':hash' do
        it 'returns a HashResponse' do
          target.with_hash_response.should be_a(Protocol::HashResponse)
        end
      end

      context ':single_value' do
        it 'returns a SingleValueResponse' do
          target.with_single_value_response.should be_a(Protocol::SingleValueResponse)
        end
      end

      context ':list' do
        it 'returns a ListResponse' do
          target.with_list_response.should be_a(Protocol::ListResponse)
        end
      end

      context ':grouped' do
        it 'returns a GroupedResponse' do
          target.with_grouped_response.should be_a(Protocol::GroupedResponse)
        end
      end
    end
  end
end
