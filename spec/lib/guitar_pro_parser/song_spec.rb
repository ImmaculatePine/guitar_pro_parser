require 'spec_helper'

describe GuitarProParser::Song do

  shared_examples 'Any Guitar Pro version' do
    its(:title) { should == 'Song Title' }
    its(:subtitle) { should == 'Song Subtitle' }
    its(:artist) { should == 'Artist' }
    its(:composer) { should == 'Composer' }
    its(:copyright) { should == 'Copyright' }
    its(:transcriber) { should == 'Transcriber' }
    its(:instructions) { should == 'Instructions' }
    its(:notices) { should include('Notice 1', 'Notice 2', 'Notice 3') }
    its(:master_volume) { should == 100 }
    its(:tempo) { should == 'Moderate' }
    its(:bpm) { should == 120 }
    its(:page_setup) { should be_kind_of GuitarProParser::PageSetup }
    its('channels.count') { should == 64 }
    pending 'midi channels data'
    its('musical_directions.count') { should == 19 }
    its(:equalizer) { should == Array.new(11, 0) }

    its('bars_settings.count') { should == 18 }
    its('tracks.count') { should == 10 }
  end

  shared_examples 'Guitar Pro 4 and 5' do
    its(:lyrics_track) { should == 1 }

    it 'should determine lyrics' do
      5.times do |i|
        subject.lyrics.should include( {text: "Lyrics line #{i+1}", bar: i+1} )
      end
    end

    its(:key) { should == 1 }
    its(:octave) { should == 0 }
  end

  shared_examples 'Guitar Pro 3 and 4' do
    its(:lyricist) { should == '' }
    its(:triplet_feel) { should == true }
    its(:master_reverb) { should == 0 }
  end


  describe 'Guitar Pro 5' do
    subject { GuitarProParser::Song.new test_tab_path 5 }

    it_behaves_like 'Any Guitar Pro version'
    it_behaves_like 'Guitar Pro 4 and 5'

    its(:version) { should == 5.1 }
    its(:lyricist) { should == 'Lyricist' }
    its(:triplet_feel) { should == false }
    
    it 'has proper musical directions' do
      subject.musical_directions.each do |key, value|
        value.should == nil
      end
    end

    its(:master_reverb) { should == 1 }
  end

  describe 'Guitar Pro 4' do
    subject { GuitarProParser::Song.new test_tab_path 4 }
    
    it_behaves_like 'Any Guitar Pro version'
    it_behaves_like 'Guitar Pro 3 and 4'
    it_behaves_like 'Guitar Pro 4 and 5'

    its(:version) { should == 4.06 }
  end

  describe 'Musical directions' do
    subject { GuitarProParser::Song.new test_tab_path 5, 'test_musical_directions' }

    it 'has proper musical directions' do
      correct_values = {
        coda: 1, 
        double_coda: 2, 
        segno: 3, 
        segno_segno: 4, 
        fine: 5, 
        da_capo: 6,
        da_capo_al_coda: 7, 
        da_capo_al_double_coda: 8, 
        da_capo_al_fine: 9,
        da_segno: 10, 
        da_segno_segno: 11, 
        da_segno_al_coda: 12, 
        da_segno_al_double_coda: 13,
        da_segno_segno_al_coda: 14,
        da_segno_segno_al_double_coda: 15, 
        da_segno_al_fine: 16, 
        da_segno_segno_al_fine: 17,
        da_coda: 18, 
        da_double_coda: 19
      }

      subject.musical_directions.each do |key, value|
        value.should == correct_values[key]
      end
    end
  end

  # TODO: Create GP3 file for testing purposes
  # describe 'Guitar Pro 3' do
  #   subject { GuitarProParser::Song.new test_tab_path 3 }

  #   it_behaves_like 'Any Guitar Pro version'
  #   it_behaves_like 'Guitar Pro 3 and 4'

  #   its(:version) { should == 3.0 }
  #   its(:lyrics_track) { should be_nil }
  #   its(:lyrics) { should be_nil }
  #   its(:key) { should == 0 }
  #   its(:octave) { should be_nil }
  
  # end
end