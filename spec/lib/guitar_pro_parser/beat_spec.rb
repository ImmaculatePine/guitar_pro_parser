require 'spec_helper'

def test_beat(type)
  beats = {
    first: [0, 0, 0],
    second: [0, 0, 1],
    third: [0, 0, 2],
    mix_table: [1, 2, 0]
  }
  track = beats[type][0]
  bar = beats[type][1]
  beat = beats[type][2]
  subject { song.tracks[track].bars[bar].get_beat(beat) }
end

describe GuitarProParser::Beat do

  shared_examples 'any Guitar Pro version' do
    context '1 beat, 1 bar, 1 track' do
      test_beat :first

      its(:dotted) { should == false }
      its(:chord_diagram) { should be_kind_of GuitarProParser::ChordDiagram }
      its(:tuplet) { should be_nil }
      its(:rest) { should be_nil }

      its(:duration) { should == :eighth }
      its(:text) { should == 'First beat' }
      its(:effects) { should == {} }
      its(:mix_table) { should be_nil }
      its('strings.count') { should == 1 }
      its(:strings) { should include '5' }
      its(:transpose) { should be_nil }
    end

    context '2 beat, 1 bar, 1 track' do
      test_beat :second
      its(:text) { should == 'Second beat' }
      its('strings.count') { should == 1 }
      its(:strings) { should include '5' }
    end

    context '3 beat, 1 bar, 1 track' do
      test_beat :third
      its(:text) { should == 'Third beat' }
      its('strings.count') { should == 1 }
      its(:strings) { should include '4' }
    end
  end

  context 'Guitar Pro 5' do
    subject(:song) { GuitarProParser::Song.new test_tab_path 5 }
    it_behaves_like 'any Guitar Pro version'

    context 'mix table' do
      test_beat :mix_table
      its(:mix_table) { should == {:instrument=>25, 
                                   :volume=>{:value=>14, :transition=>2, :apply_to=>:all},
                                   :chorus=>{:value=>2, :transition=>0, :apply_to=>:current},
                                   :phaser=>{:value=>3, :transition=>1, :apply_to=>:current}, 
                                   :rse_effect_2=>"Acoustic - Default", :rse_effect_1=>"Acoustic Tones"} }
    end
  end

  context 'Guitar Pro 4' do
    subject(:song) { GuitarProParser::Song.new test_tab_path 4 }
    it_behaves_like 'any Guitar Pro version'

    context 'mix table' do
      test_beat :mix_table
      its(:mix_table) { should == {:instrument=>25, 
                                   :volume=>{:value=>14, :transition=>2, :apply_to=>:all},
                                   :chorus=>{:value=>2, :transition=>0, :apply_to=>:current},
                                   :phaser=>{:value=>3, :transition=>1, :apply_to=>:current}} }
    end
  end
  
   
end