require 'spec_helper'

RSpec.describe GuitarProParser::BarSettings do
  
  shared_context 'shared bar 1' do
    subject { song.bars_settings[0] }
  end

  shared_context 'shared bar 2' do
    subject { song.bars_settings[1] }
  end

  shared_context 'shared bar 3' do
    subject { song.bars_settings[2] }
  end

  shared_context 'shared 3/4 bar' do
    subject { song.bars_settings[6] }
  end

  shared_context 'shared 5/8 bar' do
    subject { song.bars_settings[7] }
  end

  shared_context 'shared has start of repeat' do
    subject { song.bars_settings[8] }
  end

  shared_context 'shared has end of repeat' do
    subject { song.bars_settings[9] }
  end

  shared_context 'shared has number of alternate ending' do
    subject { song.bars_settings[12] }
  end

  shared_examples 'Any Guitar Pro version' do
    context 'bar 1' do
      include_context 'shared bar 1'

      its(:new_time_signature) { is_expected.to include(:numerator => 4, :denominator => 4) }
      its(:has_start_of_repeat) { is_expected.to eq(false) }
      its(:has_end_of_repeat) { is_expected.to eq(false) }
      its(:repeats_count) { is_expected.to eq(0) }
      its(:alternate_endings) { is_expected.to eq([]) }
      its(:marker) { is_expected.to eq({ name: 'Pt. 1', color: [255, 0, 0] }) }
      its(:new_key_signature) { is_expected.to eq({ key: 1, scale: :major }) }
      its(:double_bar) { is_expected.to eq(true) }
    end

    context 'bar 2' do
      include_context 'shared bar 2'
      its(:marker) { is_expected.to eq({ name: 'Second bar', color: [0, 255, 0] }) }
    end

    context 'bar 3' do
      include_context 'shared bar 3'
      its(:marker) { is_expected.to eq({ name: 'Pt. 2', color: [255, 0, 0] }) }
    end

    context '3/4 bar' do
      include_context 'shared 3/4 bar'
      its(:new_time_signature) { is_expected.to include(numerator: 3, denominator: nil) }
    end

    context '5/8 bar' do
      include_context 'shared 5/8 bar'
      its(:new_time_signature) { is_expected.to include(numerator: 5, denominator: 8) }
    end

    context 'has start of repeat' do
      include_context 'shared has start of repeat'
      its(:has_start_of_repeat) { is_expected.to eq(true) }
      its(:has_end_of_repeat) { is_expected.to eq(false) }
    end

    context 'has end of repeat' do
      include_context 'shared has end of repeat'
      its(:has_start_of_repeat) { is_expected.to eq(false) }
      its(:has_end_of_repeat) { is_expected.to eq(true) }
      its(:repeats_count) { is_expected.to eq(1) }
    end

    context 'has number of alternate ending' do
      include_context 'shared has number of alternate ending'
      its(:alternate_endings) { is_expected.not_to be_empty }

      # There is also end of repeat in this bar
      its(:has_end_of_repeat) { is_expected.to eq(true) }
      its(:repeats_count) { is_expected.to eq(2) }
    end
  end


  describe 'Guitar Pro 5' do
    subject(:song) { GuitarProParser::Song.new test_tab_path 5 }

    it_behaves_like 'Any Guitar Pro version'

    context 'bar 1' do
      include_context 'shared bar 1'
      its(:new_time_signature) { is_expected.to include(beam_eight_notes_by_values: [2, 2, 2, 2]) }
      its(:triplet_feel) { is_expected.to eq(:triplet_8th) }
    end

    context 'bar 2' do
      include_context 'shared bar 2'
      its(:triplet_feel) { is_expected.to eq(:no_triplet_feel) }
    end

    context 'bar 3' do
      include_context 'shared bar 3'
      its(:triplet_feel) { is_expected.to eq(:triplet_16th) }
    end

    context '3/4 bar' do
      include_context 'shared 3/4 bar'
      its(:new_time_signature) { is_expected.to include(beam_eight_notes_by_values: [2, 2, 2, 0]) }
    end

    context '5/8 bar' do
      include_context 'shared 5/8 bar'
      its(:new_time_signature) { is_expected.to include(beam_eight_notes_by_values: [3, 2, 0, 0]) }
    end

    context 'has number of alternate ending' do
      include_context 'shared has number of alternate ending'
      its(:alternate_endings) { is_expected.to eq([1, 2]) }
    end
  end  


  shared_examples 'any bar in Guitar Pro < 5' do
    its(:triplet_feel) { is_expected.to eq(:no_triplet_feel) }
  end

  describe 'Guitar Pro 4' do
    subject(:song) { GuitarProParser::Song.new test_tab_path 4 }

    it_behaves_like 'Any Guitar Pro version'

    context 'bar 1' do
      include_context 'shared bar 1'
      it_behaves_like 'any bar in Guitar Pro < 5'
      its(:new_time_signature) { is_expected.to include(beam_eight_notes_by_values: []) }
    end

    context 'bar 2' do
      include_context 'shared bar 2'
      it_behaves_like 'any bar in Guitar Pro < 5'
    end

    context 'bar 3' do
      include_context 'shared bar 3'
      it_behaves_like 'any bar in Guitar Pro < 5'
    end

    context '3/4 bar' do
      include_context 'shared 3/4 bar'
      it_behaves_like 'any bar in Guitar Pro < 5'
      its(:new_time_signature) { is_expected.to include(beam_eight_notes_by_values: []) }
    end

    context '5/8 bar' do
      include_context 'shared 5/8 bar'
      it_behaves_like 'any bar in Guitar Pro < 5'
      its(:new_time_signature) { is_expected.to include(beam_eight_notes_by_values: []) }
    end

    context 'has number of alternate ending' do
      include_context 'shared has number of alternate ending'
      its(:alternate_endings) { is_expected.to eq([2]) }
    end
  end  
  
end
