require 'spec_helper'

describe FuzzyMatch do
  context 'when no opts are passed' do
    let(:fuzzy_match) { FuzzyMatch.new('foo', ['fob', 'fab']) }

    it 'sets the margin as 2' do
      expect(fuzzy_match.instance_variable_get(:@margin)).to eq(2)
    end

    it 'returns the closest word to the original' do
      expect(fuzzy_match.closest).to eq('fob')
    end
  end

  context 'when opts are passed' do
    let(:fuzzy_match) { FuzzyMatch.new('foo', ['aaa', 'fbb'], {'margin' => 1 }) }

    it 'sets the margin to what was passed' do
      expect(fuzzy_match.instance_variable_get(:@margin)).to eq(1)
    end

    it 'returns the closest word to the original' do
      expect(fuzzy_match.closest).to eq('fbb')
    end
  end
end
