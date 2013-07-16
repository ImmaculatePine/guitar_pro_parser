require 'spec_helper'

describe GuitarProParser::PageSetup do
  subject do
    song = GuitarProParser::Song.new test_tab_path 5
    song.page_setup
  end

  its(:page_format_length) { should == 210 }
  its(:page_format_width) { should == 41 }
  its(:left_margin) { should == 10 }
  its(:right_margin) { should == 10 }
  its(:top_margin) { should == 15 }
  its(:bottom_margin) { should == 10 }
  its(:score_size) { should == 100 }

  its(:fields_bitmask) { should == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] } # TODO

  its(:title) { should == '%TITLE%' }
  its(:subtitle) { should == '%SUBTITLE%' }
  its(:artist) { should == '%ARTIST%' }
  its(:album) { should == '%ALBUM%' }
  its(:lyrics_author) { should == 'Words by %WORDS%' }
  its(:music_author) { should == 'Music by %MUSIC%' }
  its(:lyrics_and_music_author) { should == 'Words & Music by %WORDSMUSIC%' }
  its(:copyright_line_1) { should == 'Copyright %COPYRIGHT%' }
  its(:copyright_line_2) { should == 'All Rights Reserved - International Copyright Secured' }
  its(:page_number) { should == 'Page %N%/%P%' }
end