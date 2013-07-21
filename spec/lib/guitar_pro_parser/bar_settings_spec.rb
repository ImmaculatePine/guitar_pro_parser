require 'spec_helper'

describe GuitarProParser::BarSettings do
  
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
      
      its(:time_signature_change_numenator) { should == true}
      its(:time_signature_change_denomenator) { should == true}
      its(:has_start_of_repeat) { should == false }
      its(:has_end_of_repeat) { should == false }
      its(:has_number_of_alternate_ending) { should == false }
      its(:has_marker) { should == true }
      its(:key_signature_change) { should == true }
      its(:double_bar) { should == true }
                 
      its(:time_signature_numenator) { should == 4}
      its(:time_signature_denomenator) { should == 4}
      its(:repeats_count) { should == nil }
      its(:number_of_alternate_ending) { should be_nil }
      its(:marker_name) { should == 'Pt. 1' }
      its(:marker_color) { should == [255, 0, 0] }
      its(:key) { should == 1 }
      its(:scale) { should == :major }
    end

    context 'bar 2' do
      include_context 'shared bar 2'
      its(:marker_name) { should == 'Second bar' }
      its(:marker_color) { should == [0, 255, 0] }
    end

    context 'bar 3' do
      include_context 'shared bar 3'
      its(:marker_name) { should == 'Pt. 2' }
    end

    context '3/4 bar' do
      include_context 'shared 3/4 bar'
      its(:time_signature_change_numenator) { should == true}
      its(:time_signature_change_denomenator) { should == false}
      its(:time_signature_numenator) { should == 3}
      its(:time_signature_denomenator) { should be_nil}
    end

    context '5/8 bar' do
      include_context 'shared 5/8 bar'
      its(:time_signature_change_numenator) { should == true}
      its(:time_signature_change_denomenator) { should == true}
      its(:time_signature_numenator) { should == 5}
      its(:time_signature_denomenator) { should == 8}
    end

    context 'has start of repeat' do
      include_context 'shared has start of repeat'
      its(:has_start_of_repeat) { should == true }
      its(:has_end_of_repeat) { should == false }
    end

    context 'has end of repeat' do
      include_context 'shared has end of repeat'
      its(:has_start_of_repeat) { should == false }
      its(:has_end_of_repeat) { should == true }
      its(:repeats_count) { should == 1 }
    end

    context 'has number of alternate ending' do
      include_context 'shared has number of alternate ending'
      its(:has_number_of_alternate_ending) { should == true }

      # There is also end of repeat in this bar
      its(:has_end_of_repeat) { should == true }
      its(:repeats_count) { should == 2 }
    end
  end


  describe 'Guitar Pro 5' do
    subject(:song) { GuitarProParser::Song.new test_tab_path 5 }

    it_behaves_like 'Any Guitar Pro version'

    context 'bar 1' do
      include_context 'shared bar 1'
      its(:beam_eight_notes_by_values) { should == [2, 2, 2, 2] }
      its(:triplet_feel) { should == :triplet_8th }
    end

    context 'bar 2' do
      include_context 'shared bar 2'
      its(:beam_eight_notes_by_values) { should be_nil }
      its(:triplet_feel) { should == :no_triplet_feel }
    end

    context 'bar 3' do
      include_context 'shared bar 3'
      its(:beam_eight_notes_by_values) { should be_nil }
      its(:triplet_feel) { should == :triplet_16th }
    end

    context '3/4 bar' do
      include_context 'shared 3/4 bar'
      its(:beam_eight_notes_by_values) { should == [2, 2, 2, 0] }
    end

    context '5/8 bar' do
      include_context 'shared 5/8 bar'
      its(:beam_eight_notes_by_values) { should == [3, 2, 0, 0] }
    end

    context 'has number of alternate ending' do
      include_context 'shared has number of alternate ending'
      its(:number_of_alternate_ending) { should == [1, 2] }
    end
  end  


  shared_examples 'any bar in Guitar Pro < 5' do
    its(:beam_eight_notes_by_values) { should == nil }
    its(:triplet_feel) { should == nil }
  end

  describe 'Guitar Pro 4' do
    subject(:song) { GuitarProParser::Song.new test_tab_path 4 }

    it_behaves_like 'Any Guitar Pro version'

    context 'bar 1' do
      include_context 'shared bar 1'
      it_behaves_like 'any bar in Guitar Pro < 5'
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
    end

    context '5/8 bar' do
      include_context 'shared 5/8 bar'
      it_behaves_like 'any bar in Guitar Pro < 5'
    end

    context 'has number of alternate ending' do
      include_context 'shared has number of alternate ending'
      its(:number_of_alternate_ending) { should == [2] }
    end
  end  
  
end