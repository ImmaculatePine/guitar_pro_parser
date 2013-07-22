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
  
  Require the library:

    require 'guitar_pro_parser'

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

  All available methods and attributes could be found in the source code. :)
  
  TODO: Write documentation.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
