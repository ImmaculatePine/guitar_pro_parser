require 'spec_helper'

def test_track(test_type)
  refs = {
    n1: 0,
    n2: 1,
    percussion: 2,
    seven_strings: 3,
    green_colored: 3,
    drop_d: 4,
    with_more_frets: 4,
    with_capo: 4,
    twelve_strings: 5,
    banjo: 6,
    with_all_styles: 7,
    auto_let_ring: 3,
    auto_brush: 4,
    with_custom_midi_bank: 8,
    with_human_playing: 9,
    with_auto_accentuation: 9,
    with_equalizer: 9,
    with_custom_sound_bank: 9,
    muted: 4
  }

  subject {song.tracks[refs[test_type]]}
end

describe GuitarProParser::Track do

  shared_examples 'default track of any version' do
    its(:drums) { should == false }
    its(:twelve_stringed_guitar) { should == false }
    its(:banjo) { should == false }
    its(:solo_playback) { should == false }
    its(:mute_playback) { should == false }
    its(:rse_playback) { should == false }
    its(:indicate_tuning) { should == false }
    its(:strings_count) { should == 6 }
    its(:strings_tuning) { should == %w(E5 B4 G4 D4 A3 E3) }
    its(:midi_port) { should == 1 }
    its(:frets_count) { should == 24 }
    its(:capo) { should == 0 }
    its(:color) { should == [255, 0, 0] }
  end

  shared_examples 'default track v5' do
    its(:diagrams_below_the_standard_notation) { should == false }
    its(:show_rythm_with_tab) { should == false }
    its(:force_horizontal_beams) { should == false }
    its(:force_channels_11_to_16) { should == false }
    its(:diagrams_list_on_top_of_score) { should == true }
    its(:diagrams_in_the_score) { should == false }
    its(:extend_rhytmic_inside_the_tab) { should == false }
    its(:auto_let_ring) { should == false }
    its(:auto_brush) { should == false }
    

    its(:midi_bank) { should == 0 }
    its(:human_playing) { should == 0 }
    its(:auto_accentuation) { should == 0 }
    its(:sound_bank) { should == 255 }
    its(:equalizer) { should == [0, 0, 0, 0] }
    
  end
 
  shared_examples 'Any Guitar Pro version' do
    
    context 'track 1' do
      test_track :n1
      it_behaves_like 'default track of any version'
      its(:name) { should == 'Track 1' }
      its(:midi_channel) { should == 1 }
      its(:midi_channel_for_effects) { should == 2 }
    end

    context 'track 2' do
      test_track :n2
      it_behaves_like 'default track of any version'
      its(:name) { should == 'Track 2' }
      its(:midi_channel) { should == 3 }
      its(:midi_channel_for_effects) { should == 4 }
    end

    context 'percussion' do
      test_track :percussion
      its(:drums) { should == true }
      its(:name) { should == 'Percussion' }
      its(:midi_channel) { should == 10 }
      its(:midi_channel_for_effects) { should == 10 }
    end

    context '7 strings guitar' do
      test_track :seven_strings
      its(:name) { should == '7 string guitar' }
      its(:strings_count) { should == 7 }
      its(:strings_tuning) { should == %w(E5 B4 G4 D4 A3 E3 B2) }
    end

    context 'green colored' do
      test_track :green_colored
      its(:color) { should == [0, 255, 0] }
    end

    context 'drop D' do
      test_track :drop_d
      its(:strings_count) { should == 6 }
      its(:strings_tuning) { should == %w(D5 A4 F4 C4 G3 C3) } # actually it is drop C
    end

    context 'with more frets' do
      test_track :with_more_frets
      its(:frets_count) { should == 27 }
    end

    context 'with capo' do
      test_track :with_capo
      its(:capo) { should == 3 }
    end

    context '12 strings' do
      test_track :twelve_strings
      its(:name) { should == '12 stringed guitar' }
      its(:strings_count) { should == 6 }
      its(:twelve_stringed_guitar) { should == true }
    end

    context 'banjo' do
      test_track :banjo
      its(:name) { should == 'Banjo' }
      its(:strings_count) { should == 5 }
      its(:banjo) { should == true }
    end
  end


  describe 'Guitar Pro 5' do
    subject(:song) { GuitarProParser::Song.new test_tab_path 5 }

    it_behaves_like 'Any Guitar Pro version'

    context 'track 1' do
      test_track :n1
      it_behaves_like 'default track v5'
      its(:instrument_effect_1) { should == 'American Clean - Pi Distortion' }
      its(:instrument_effect_2) { should == 'Amp Tones' }      
    end

    context 'track 2' do
      test_track :n2
      it_behaves_like 'default track v5'
      its(:instrument_effect_1) { should == 'Acoustic - Default' }
      its(:instrument_effect_2) { should == 'Acoustic Tones' }
    end

    context 'with all styles' do
      test_track :with_all_styles
      its(:diagrams_below_the_standard_notation) { should == true }
      its(:show_rythm_with_tab) { should == true }
      its(:force_horizontal_beams) { should == true }
      its(:diagrams_list_on_top_of_score) { should == true }
      its(:diagrams_in_the_score) { should == true }
      its(:extend_rhytmic_inside_the_tab) { should == true }
    end

    context 'auto let ring' do
      test_track :auto_let_ring
      its(:auto_let_ring) { should == true }
    end
    
    context 'auto brush' do
      test_track :auto_brush
      its(:auto_brush) { should == true }
    end

    context 'with custom midi bank' do
      test_track :with_custom_midi_bank
      its(:midi_bank) { should == 5 }
    end

    context 'with human playing' do
      test_track :with_human_playing
      its(:human_playing) { should == 15 }
    end

    pending 'with auto accentuation'

    context 'with equalizer' do
      test_track :with_equalizer
      its(:equalizer) { should == [226, 60, 231, 246] }
    end

    context 'with custom sound bank' do
      test_track :with_custom_sound_bank
      its(:sound_bank) { should == 2 }
    end

    context 'muted' do
      test_track :muted
      its(:mute_playback) { should == true }
    end
  end  

  describe 'Guitar Pro 4' do
    subject(:song) { GuitarProParser::Song.new test_tab_path 4 }
    it_behaves_like 'Any Guitar Pro version'

    context 'muted' do
      test_track :muted
      its(:mute_playback) { should == false }
    end
  end  
  
end