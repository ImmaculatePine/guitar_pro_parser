require 'spec_helper'

describe GuitarProParser::Channel do

  shared_examples 'any Guitar Pro version' do
    context 'port 1, channel 1' do
      subject { song.channels[0][0] }

      its(:instrument) { should == 30 }
      its(:volume) { should == 13 }
      its(:pan) { should == 8 }
      its(:chorus) { should == 0 }
      its(:reverb) { should == 0 }
      its(:phaser) { should == 0 }
      its(:tremolo) { should == 0 }
    end

    context 'port 1, channel 1' do
      subject { song.channels[0][1] }
      its(:instrument) { should == 30 }
    end

    context 'port 1, channel 3' do
      subject { song.channels[0][2] }
      its(:instrument) { should == 25 }
    end

    context 'port 1, channel 10 (drums)' do
      subject { song.channels[0][9] }
      its(:instrument) { should == 0 }
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