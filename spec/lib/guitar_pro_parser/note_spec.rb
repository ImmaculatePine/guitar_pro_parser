require 'spec_helper'

# TODO: Rewrite these test when it will be possible to read all the beats and notes.

def test_note(type)
  refs = {
    first: [0, '5']
  }
  beat_number = refs.fetch(type).fetch(0)
  string_number = refs.fetch(type).fetch(1)
  subject { song.beats[beat_number].strings[string_number] }
end

describe GuitarProParser::Note do


  shared_examples 'any Guitar Pro version' do
    
    context 'note of the 1 beat, 1 bar, 1 track' do
      test_note :first

      # Tested features
      its('accentuated?') { should == false }
      its('ghost?') { should == false }

      its('has_fingering?') { should == false }
      its(:left_hand_fingering) { should be_nil }
      its(:right_hand_fingering) { should be_nil }

      its('has_dynamic?') { should == false }
      its(:dynamic) { should == 'f' }

      its('has_type?') { should == true }
      its(:type) { should == :normal }

      its(:fret) { should == 3 }

      its('has_effects?') { should == false }

      its('has_hammer_or_pull?') { should == false }

      its('let_ring?') { should == false }
 
      its('has_bend?') { should == false }
      its(:bend) { should be_nil }

      its('has_grace_note?') { should == false }
      its(:grace_note) { should be_nil }

      its('staccato?') { should == false }

      its('palm_mute?') { should == false }

      its('tremolo?') { should == false }
      its(:tremolo_speed) { should be_nil }

      its('has_slide?') { should == false }
      its(:slide) { should be_nil }
      
      its('has_harmonic?') { should == false }
      its(:harmonic) { should be_nil }

      its('vibrato?') { should == false }

      its('has_trill?') { should == false }
      its(:trill) { should be_nil }
      

      # Old version of test
      # its('time_independent_duration?') { should == false }
      # its('accentuated?') { should == false }
      # its('ghost?') { should == false }
      # its('has_effects?') { should == true }
      # its('has_dynamic?') { should == false }
      # its('has_type?') { should == true }
      # its('has_fingering?') { should == false }

      # its('has_bend?') { should == false }
      # its('has_hammer_or_pull?') { should == false }
      # its('has_slide?') { should == true }
      # its('let_ring?') { should == false }
      # its('has_grace_note?') { should == false }
      # its('staccato?') { should == false }
      # its('palm_mute?') { should == false }
      # its('tremolo?') { should == true }
      # its('has_harmonic?') { should == true }
      # its('has_trill?') { should == false }
      # its('vibrato?') { should == false }

      # its(:type) { should == :normal }
      # its(:dynamic) { should == 'f' }
      
      # its(:left_hand_fingering) { should be_nil }
      # its(:right_hand_fingering) { should be_nil }

      # its(:bend) { should be_nil }
      # its(:grace_note) { should be_nil }
      # its(:tremolo_speed) { should == 32 }
      # its(:slide) { should == :shift_slide }
      # its(:trill) { should be_nil }
   
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