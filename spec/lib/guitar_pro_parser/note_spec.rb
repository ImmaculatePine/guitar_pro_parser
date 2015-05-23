require 'spec_helper'

# TODO: It would be nice to add more tests for notes and test :bass voice

def test_note(type)
  notes = {
    first: [0, 0, 0, '5'],
    legato_slide: [0, 15, 0, '2'],
    shift_slide: [0, 15, 2, '2'],
    slide_in_from_below: [0, 15, 4, '2'],
    slide_in_from_above: [0, 15, 5, '2'],
    slide_out_and_downwards: [0, 15, 6, '2'],
    slide_out_and_upwards: [0, 15, 7, '2'],
  }
  note = notes.fetch(type)
  track_number = note[0]
  bar_number = note[1]
  beat_number = note[2]
  string_number = note[3]
  subject { song.tracks[track_number].bars[bar_number].get_beat(beat_number).strings[string_number] }
end

RSpec.describe GuitarProParser::Note do

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

    context 'legato slide' do
      test_note :legato_slide
      its(:slide) { should == [:legato_slide] }
    end

    context 'shift slide' do
      test_note :shift_slide
      its(:slide) { should == [:shift_slide] }
    end

    context 'slide in from below' do
      test_note :slide_in_from_below
      its(:slide) { should == [:slide_in_from_below] }
    end

    context 'slide in from above' do
      test_note :slide_in_from_above
      its(:slide) { should == [:slide_in_from_above] }
    end

    context 'slide out and downwards' do
      test_note :slide_out_and_downwards
      its(:slide) { should == [:slide_out_and_downwards] }
    end

    context 'slide out and upwards' do
      test_note :slide_out_and_upwards
      its(:slide) { should == [:slide_out_and_upwards] }
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