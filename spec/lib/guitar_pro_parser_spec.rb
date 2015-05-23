require 'spec_helper'

RSpec.describe GuitarProParser do
  it 'has a version' do
    expect(GuitarProParser::VERSION).not_to be_nil
  end

  shared_examples 'all Guitar Pro versions' do
    it 'is a song object' do
      expect(subject).to be_kind_of(GuitarProParser::Song)
    end

    its(:title) { is_expected.to eq('Song Title') }
    its('tracks.count') { is_expected.to eq(10) }
  end

  shared_examples 'file with headers only' do
    it 'has no data about notes' do
      subject.tracks.each do |track|
        expect(track.bars).to be_empty
      end
    end
  end


  describe '.read_file' do
    context 'Guitar Pro 5' do
      subject { GuitarProParser.read_file(test_tab_path(5)) }
      it_behaves_like 'all Guitar Pro versions'
    end

    context 'Guitar Pro 4' do
      subject { GuitarProParser.read_file(test_tab_path(4)) }
      it_behaves_like 'all Guitar Pro versions'
    end
  end

  describe '.read_headers' do
    context 'Header only Guitar Pro 5' do
      subject { GuitarProParser.read_headers(test_tab_path(5)) }
      it_behaves_like 'all Guitar Pro versions'
      it_behaves_like 'file with headers only'
    end

    context 'Header only Guitar Pro 4' do
      subject { GuitarProParser.read_headers(test_tab_path(4)) }
      it_behaves_like 'all Guitar Pro versions'
      it_behaves_like 'file with headers only'
    end
  end
end
