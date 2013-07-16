require 'spec_helper'

describe GuitarProParser::Song do

  shared_examples 'Any Guitar Pro version' do
    its(:file_path) { should_not be_nil }
    its(:title) { should == 'Song Title' }
    its(:subtitle) { should == 'Song Subtitle' }
    its(:artist) { should == 'Artist' }
    its(:composer) { should == 'Composer' }
    its(:copyright) { should == 'Copyright' }
    its(:transcriber) { should == 'Transcriber' }
    its(:instructions) { should == 'Instructions' }
    its(:notices) { should include('Notice 1', 'Notice 2', 'Notice 3') }
    its(:bpm) { should == 120 }
    its('midi_channels.count') { should == 64 }
    pending 'midi channels data'
    its(:bars_count) { should == 26 }
    its(:tracks_count) { should == 2 }
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
    its(:lyricist) { should be_nil }
    its(:triplet_feel) { should == false } # is determined
    its(:master_volume) { should be_nil }
    its(:equalizer) { should be_nil }
    its(:page_setup) { should be_nil}
    its(:tempo) { should be_nil }
    its(:directions_definitions) { should be_nil }
    its(:master_reverb) { should be_nil }
  end


  describe 'Guitar Pro 5' do
    subject { GuitarProParser::Song.new test_tab_path 5 }

    it_behaves_like 'Any Guitar Pro version'
    it_behaves_like 'Guitar Pro 4 and 5'

    its(:version) { should == 5.1 }
    its(:lyricist) { should == 'Lyricist' }
    its(:triplet_feel) { should be_nil }
    its(:master_volume) { should == 100 }
    
    it 'should determine equalizer settings' do
      equalizer = []
      11.times { equalizer << 0 }
      subject.equalizer.should == equalizer
    end

    its(:page_setup) { should be_kind_of GuitarProParser::PageSetup }
    its(:tempo) { should == 'Moderate' }
    its('directions_definitions.count') { should == 19 }
    
    it 'has proper musical directions definitions' do
      correct_values = {
        coda: 7, 
        double_coda: 8, 
        segno: 9, 
        segno_segno: 10, 
        fine: 11, 
        da_capo: 12,
        da_capo_al_coda: 13, 
        da_capo_al_double_coda: 14, 
        da_capo_al_fine: 15,
        da_segno: 16, 
        da_segno_segno: 17, 
        da_segno_al_coda: 18, 
        da_segno_al_double_coda: 19,
        da_segno_segno_al_coda: 20,
        da_segno_segno_al_double_coda: 21, 
        da_segno_al_fine: 22, 
        da_segno_segno_al_fine: 23,
        da_coda: 24, 
        da_double_coda: 25
      }

      subject.directions_definitions.each do |key, value|
        value.should == correct_values[key]
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

  # TODO Create GP3 file for testing purposes
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