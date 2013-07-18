require 'spec_helper'

describe GuitarProParser::Beat do


  shared_examples 'any Guitar Pro version' do
    context '1 beat, 1 bar, 1 track' do
      subject { song.beats[0] }

      its('dotted?') { should == false }
      its('has_chord_diagram?') { should == false }
      its('has_text?') { should == true }
      its('has_effects?') { should == false }
      its('has_mix_table_change?') { should == false }
      its('tuplet?') { should == false }
      its('rest?') { should == false }

      its(:duration) { should == :eighth }
      its(:rest_type) { should be_nil }
      its(:tuplet_type) { should be_nil }
      its(:chord_diagram) { should be_nil }
      its(:text) { should == 'First beat' }
      its(:effects) { should == {} }
      its(:mix_table) { should be_nil }
      its('strings.count') { should == 1 }
      its(:strings) { should include '5' }
      its(:transpose) { should be_nil }
    end

    context '2 beat, 1 bar, 1 track' do
      subject { song.beats[1] }
      its(:text) { should == 'Second beat' }
      its('strings.count') { should == 1 }
      its(:strings) { should include '5' }
    end

    context '3 beat, 1 bar, 1 track' do
      subject { song.beats[2] }
      its(:text) { should == 'Third beat' }
      its('strings.count') { should == 1 }
      its(:strings) { should include '4' }
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