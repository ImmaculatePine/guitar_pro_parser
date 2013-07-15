require 'spec_helper'

describe GuitarProParser::Song do

  shared_examples "Any Guitar Pro version" do
    it "should has filename" do
      subject.file_path.should_not be_nil
    end

    it "should determine title" do
      subject.title.should == 'Song Title'
    end

    it "should determine subtitle" do
      subject.subtitle.should == 'Song Subtitle'
    end

    it "should determine artist" do
      subject.artist.should == 'Artist'
    end

    it "should determine composer" do
      subject.composer.should == 'Composer'
    end

    it "should determine copyright" do
      subject.copyright.should == 'Copyright'
    end

    it "should determine transcriber" do
      subject.transcriber.should == 'Transcriber'
    end
    
    it "should determine instructions" do
      subject.instructions.should == 'Instructions'
    end

    it "should determine notices" do
      subject.notices.should include('Notice 1', 'Notice 2', 'Notice 3')
    end
  end

  shared_examples "Guitar Pro 4 and 5" do
    it "should determine lyrics" do
      subject.lyrics_track.should == 1
      5.times do |i|
        subject.lyrics.should include( {text: "Lyrics line #{i+1}", bar: i+1} )
      end
    end
  end

  shared_examples "Guitar Pro 3 and 4" do
    it "should not have lyricist" do
      subject.lyricist.should be_nil
    end

    it "should determine triplet feel" do
      subject.triplet_feel.should == false
    end

    it "should not have master volume" do
      subject.master_volume.should be_nil
    end

    it "should not have equalizer" do
      subject.equalizer.should be_nil
    end
  end

  describe "Guitar Pro 5" do
    subject { GuitarProParser::Song.new 'spec/tabs/tab.gp5' }

    it_behaves_like "Any Guitar Pro version"
    it_behaves_like "Guitar Pro 4 and 5"

    it "should determine Guitar Pro version" do
      subject.version.should == 5.1
    end
    
    it "should determine lyricist" do
      subject.lyricist.should == 'Lyricist'
    end

    it "should not have triplet feel" do
      subject.triplet_feel.should == false
    end

    it "should determine master volume" do
      subject.master_volume.should == 100
    end

    it "should determine equalizer settings" do
      equalizer = []
      11.times do
        equalizer << 0
      end
      subject.equalizer.should == equalizer
    end
  end

  describe "Guitar Pro 4" do
    subject { GuitarProParser::Song.new 'spec/tabs/tab.gp4' }
    
    it_behaves_like "Any Guitar Pro version"
    it_behaves_like "Guitar Pro 3 and 4"
    it_behaves_like "Guitar Pro 4 and 5"

    it "should determine Guitar Pro version" do
      subject.version.should == 4.06
    end
  end

  # TODO Create GP3 file for testing purposes
  # describe "Guitar Pro 3" do
  #   subject { GuitarProParser::Song.new 'spec/tabs/version3.gp3' }

  #   it_behaves_like "Any Guitar Pro version"
  #   it_behaves_like "Guitar Pro 3 and 4"

  #   it "should determine Guitar Pro version" do
  #     subject.version.should == 3.0
  #   end
  # end
end