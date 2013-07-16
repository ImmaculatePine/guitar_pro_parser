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
  end

  shared_examples 'Guitar Pro 4 and 5' do
    its(:lyrics_track) { should == 1 }

    it 'should determine lyrics' do
      5.times do |i|
        subject.lyrics.should include( {text: "Lyrics line #{i+1}", bar: i+1} )
      end
    end
  end

  shared_examples 'Guitar Pro 3 and 4' do
    its(:lyricist) { should be_nil }
    its(:triplet_feel) { should == false } # is determined
    its(:master_volume) { should be_nil }
    its(:equalizer) { should be_nil }
    its(:page_setup) { should be_nil}
  end


  describe 'Guitar Pro 5' do
    subject { GuitarProParser::Song.new 'spec/tabs/tab.gp5' }

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
  end

  describe 'Guitar Pro 4' do
    subject { GuitarProParser::Song.new 'spec/tabs/tab.gp4' }
    
    it_behaves_like 'Any Guitar Pro version'
    it_behaves_like 'Guitar Pro 3 and 4'
    it_behaves_like 'Guitar Pro 4 and 5'

    its(:version) { should == 4.06 }
  end

  # TODO Create GP3 file for testing purposes
  # describe 'Guitar Pro 3' do
  #   subject { GuitarProParser::Song.new 'spec/tabs/version3.gp3' }

  #   it_behaves_like 'Any Guitar Pro version'
  #   it_behaves_like 'Guitar Pro 3 and 4'

  #   its(:version) { should == 3.0 }
  #   its(:lyrics_track) { should be_nil }
  #   its(:lyrics) { should be_nil }
  
  # end
end