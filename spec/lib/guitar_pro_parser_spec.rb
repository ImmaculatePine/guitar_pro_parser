require 'spec_helper'

describe GuitarProParser do
  it 'should has a version' do
    GuitarProParser::VERSION.should_not be_nil
  end

  shared_examples 'all Guitar Pro versions' do
    it 'is a song object' do
      subject.should be_kind_of GuitarProParser::Song
    end

    its(:title) { should == 'Song Title'}
    its('tracks.count') { should == 10 }
  end

  shared_examples 'file with headers only' do
    it 'has no data about notes' do
      subject.tracks.each do |track|
        track.bars.should be_empty
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