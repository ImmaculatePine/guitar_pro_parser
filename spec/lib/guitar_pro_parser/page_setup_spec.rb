require 'spec_helper'

RSpec.describe GuitarProParser::PageSetup do
  subject { GuitarProParser::Song.new(test_tab_path(5)).page_setup }

  its(:page_format_length) { should == 210 }
  its(:page_format_width) { should == 297 }
  its(:left_margin) { should == 10 }
  its(:right_margin) { should == 10 }
  its(:top_margin) { should == 15 }
  its(:bottom_margin) { should == 10 }
  its(:score_size) { should == 100 }

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

  its(:displayed_fields) { should == [:title, :subtitle, :artist, :album, :lyrics_author, :music_author, :lyrics_and_music_author, :copyright, :page_number] }
end