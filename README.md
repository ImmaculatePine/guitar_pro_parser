# GuitarProParser

It is a gem for Ruby that allows to read Guitar Pro files.
Now it supports Guitar Pro 4 and 5 files. Version 3 should work but is not tested at all.

## Installation

Add this line to your application's Gemfile:

    gem 'guitar_pro_parser'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install guitar_pro_parser

## Usage
  
  Read the file:

    song = GuitarProParser.read_file('path_to_file')

  Now you can access song's properties like that:

    # Get some attributes of the song
    puts song.title
    puts song.artist
    puts song.bpm

    # Or read notes
    song.tracks.each do |track|
      track.bars.each do |bar|
        puts "There are #{bar.voices[:lead].count} beats in lead voice"
        puts "There are #{bar.voices[:bass].count} beats in bass voice" unless bar.voices[:bass].nil?

        bar.voice[:lead] do |beat|
          beat.strings.each do |string, note|
            puts "Play #{string} string on the #{note.fret} fret."
            puts "Note's duration is #{note.duration}"
          end
        end
      end
    end

  If you don't need any information about beats, notes and other music stuff you can read headers only:

    song = GuitarProParser.read_headers('path_to_file')

    # You'll have title, subtitle, artist, etc.
    song.title # => 'Title'

    # But no notes
    song.tracks.first.bars # => []

  All available methods and attributes could be found in the source code. :)

  You can also export song object to JSON format:

    puts song.to_json
    # {"meta":{"version":4.0,"title":"Song Title","subtitle":"","artist":"The Artist","album":"The Album" ...
  
  TODO: Write documentation.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

If you have a tab that couldn't be read or is read incorrectly, please send it to immaculate.pine@gmail.com or create an issue on Github with description of bug.