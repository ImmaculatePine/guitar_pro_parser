require 'spec_helper'

describe GuitarProParser do
  it 'should has a version' do
    GuitarProParser::VERSION.should_not be_nil
  end

  describe '.read_file' do
    shared_examples 'all Guitar Pro versions' do
      it 'is a song object' do
        subject.should be_kind_of GuitarProParser::Song
      end

      its(:title) { should == 'Song Title'}
      its('tracks.count') { should == 10 }
    end

    context 'Guitar Pro 5' do
      subject { GuitarProParser.read_file(test_tab_path(5)) }
    end

    context 'Guitar Pro 4' do
      subject { GuitarProParser.read_file(test_tab_path(4)) }
    end
  end
end