require 'spec_helper'

# TODO: Rewrite these test when it will be possible to read all the beats and notes.

def test_note(type)
  refs = {
    first: [0, '5']
  }
  beat_number = refs.fetch(type).fetch(0)
  string_number = refs.fetch(type).fetch(1)
  subject { song.tracks[0].bars[0].get_beat(beat_number).strings[string_number] }
end

describe GuitarProParser::Note do


  shared_examples 'any Guitar Pro version' do
    
    context 'note of the 1 beat, 1 bar, 1 track' do
      test_note :first

      # Tested features
      its(:accentuated) { should == false }
      its(:ghost) { should == false }
      its(:fingers) { should == { left: nil, right: nil } }
      its(:dynamic) { should == 'f' }
      its(:type) { should == :normal }
      its(:fret) { should == 3 }
      its(:hammer_or_pull) { should == false }
      its(:let_ring) { should == false }
      its(:bend) { should be_nil }
      its(:grace) { should be_nil }
      its(:staccato) { should == false }
      its(:palm_mute) { should == false }
      its(:tremolo) { should be_nil }
      its(:slide) { should be_nil }
      its(:harmonic) { should be_nil }
      its(:vibrato) { should == false }
      its(:trill) { should be_nil }
    end

  end

  context 'Guitar Pro 5' do
    subject(:song) { GuitarProParser::Song.new test_tab_path 5 }
    it_behaves_like 'any Guitar Pro version'
  end

  context 'Guitar Pro 4' do
    subject(:song) { GuitarProParser::Song.new test_tab_path 4 }
    it_behaves_like 'any Guitar Pro version'
  end
  
   
end