require 'spec_helper'

RSpec.describe GuitarProParser::ChordDiagram do

  shared_examples 'any Guitar Pro version' do
    context 'F#m11/9-' do
      subject { song.tracks[0].bars[0].get_beat(0).chord_diagram }
      its(:name) { should == 'F#m11/9-' }
      its(:base_fret) { should == 1 }
      its(:frets) { should == [3, 2, 4, 2, 0, 2] }
      its(:display_as) { should == :sharp }
      its(:root) { should == 'F#' }
      its(:type) { should == 'm' }
      its(:nine_eleven_thirteen) { should == 11 }
      its(:bass) { should == 'F#' }
      its(:tonality) { should == :perfect }
      its(:add) { should == false }
      its(:fifth_tonality) { should == :perfect }
      its(:ninth_tonality) { should == :diminished }
      its(:eleventh_tonality) { should == :perfect }
      its(:barres) { should == [{ fret: 2, start_string: 1, end_string: 4 }] }
      its(:intervals) { should == [13] }
      its(:fingers) { should == [:ring, :middle, :pinky, :middle, :no, :index] }
      its(:display_fingering) { should == true }
    end

    context 'Asus2add13' do
      subject { song.tracks[0].bars[0].get_beat(4).chord_diagram }
      its(:name) { should == 'Asus2add13' }
      its(:base_fret) { should == 1 }
      its(:frets) { should == [2, 0, 2, 2, 2, -1] }
      its(:display_as) { should == :sharp }
      its(:root) { should == 'A' }
      its(:type) { should == 'sus2' }
      its(:nine_eleven_thirteen) { should == 13 }
      its(:bass) { should == 'B' }
      its(:tonality) { should == :perfect }
      its(:add) { should == true }
      its(:fifth_tonality) { should == :perfect }
      its(:ninth_tonality) { should == :perfect }
      its(:eleventh_tonality) { should == :perfect }
      its(:barres) { should == [] }
      its(:intervals) { should == [7, 9, 11] }
      its(:fingers) { should == [:pinky, :no, :ring, :middle, :index, :no] }
      its(:display_fingering) { should == true }
    end

     context 'C7M13+/9-/11-' do
      subject { song.tracks[0].bars[1].get_beat(0).chord_diagram }
      its(:name) { should == 'C7M13+/9-/11-' }
      its(:base_fret) { should == 8 }
      its(:frets) { should == [9, 11, 9, 9, 10, 8] }
      its(:display_as) { should == :sharp }
      its(:root) { should == 'C' }
      its(:type) { should == '7M' }
      its(:nine_eleven_thirteen) { should == 13 }
      its(:bass) { should == 'C' }
      its(:tonality) { should == :augmented }
      its(:add) { should == false }
      its(:fifth_tonality) { should == :perfect }
      its(:ninth_tonality) { should == :diminished }
      its(:eleventh_tonality) { should == :diminished }
      its(:barres) { should == [{ fret: 9, start_string: 1, end_string: 4 }] }
      its(:intervals) { should == [] }
      its(:fingers) { should == [:middle, :pinky, :middle, :middle, :ring, :index] }
      its(:display_fingering) { should == true }
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