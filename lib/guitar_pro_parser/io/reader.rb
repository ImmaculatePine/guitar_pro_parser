require 'guitar_pro_parser/io/input_stream'
require 'guitar_pro_parser/guitar_pro_helper'

# TODO: Maybe I should move this requires to song
require "guitar_pro_parser/bar"
require "guitar_pro_parser/track"

module GuitarProParser

  class Reader

    def initialize(song, file_path)
      @song = song
      @file_path = file_path

      @input = InputStream.new(file_path)

      read_version
      read_info
      read_notices
      @song.triplet_feel = @input.read_boolean if @version < 5.0
      read_lyrics if @version >= 4.0

      if @version >= 5.0
        @song.master_volume = @input.read_integer 
        @input.skip_integer
      end

      11.times { |n| @song.equalizer[n] = @input.read_byte } if @version >= 5.0
      read_page_setup if @version >= 5.0
      read_tempo
      read_key
      @song.octave = @input.read_byte if @version >= 4.0
      read_channels
      read_musical_directions if @version >= 5.0
      @song.master_reverb = @input.read_integer if @version >= 5.0

      bars_count = @input.read_integer
      tracks_count = @input.read_integer
      read_bars_settings(bars_count)
      read_tracks(tracks_count)
      read_beats
    end

    private

    def read_version
      length = @input.read_byte
      version_string = @input.read_string length
      # TODO: Change a way to get value from string
      version_string['FICHIER GUITAR PRO v'] = ''
      @version = version_string.to_f
      @song.version = @version

      # Skip first 31 bytes that are reserved for version data
      @input.offset = 31
    end

    def read_info
      @song.title = @input.read_chunk
      @song.subtitle = @input.read_chunk
      @song.artist = @input.read_chunk
      @song.album = @input.read_chunk
      @song.lyricist = @input.read_chunk if @version > 5.0
      @song.composer = @input.read_chunk
      @song.copyright = @input.read_chunk
      @song.transcriber = @input.read_chunk
      @song.instructions = @input.read_chunk
    end

    def read_notices
      notices = []

      notices_count = @input.read_integer
      notices_count.times { notices << @input.read_chunk }
      
      @song.notices = notices.join('/n')
    end

    # > 4.0 only
    def read_lyrics
      @song.lyrics_track = @input.read_integer

      5.times do 
        start_bar = @input.read_integer
        length = @input.read_integer
        lyrics_text = @input.read_string length
        @song.lyrics << {text: lyrics_text, bar: start_bar}
      end
    end

    #  >= 5.0 only
    def read_page_setup
      @song.page_setup.page_format_length = @input.read_integer
      @song.page_setup.page_format_width = @input.read_integer
      @song.page_setup.left_margin = @input.read_integer
      @song.page_setup.right_margin = @input.read_integer
      @song.page_setup.top_margin = @input.read_integer
      @song.page_setup.bottom_margin = @input.read_integer
      @song.page_setup.score_size = @input.read_integer

      # TODO: Read PageSetup 16-bit bitmask here
      # The enabled header/footer fields bitmask declares which fields are displayed:
      # Bit 0 (LSB):  Title field
      # Bit 1:    Subtitle field
      # Bit 2:    Artist field
      # Bit 3:    Album field
      # Bit 4:    Words (Lyricist) field
      # Bit 5:    Music (Composer) field
      # Bit 6:    Words & Music field
      # Bit 7:    Copyright field
      # Bit 8:    Page Number (field)
      # Bits 9 - 15:  Unused (set to 0)
      @input.skip_byte
      @input.skip_byte

      @song.page_setup.title = @input.read_chunk
      @song.page_setup.subtitle = @input.read_chunk
      @song.page_setup.artist = @input.read_chunk
      @song.page_setup.album = @input.read_chunk
      @song.page_setup.lyrics_author = @input.read_chunk
      @song.page_setup.music_author = @input.read_chunk
      @song.page_setup.lyrics_and_music_author = @input.read_chunk
      @song.page_setup.copyright_line_1 = @input.read_chunk
      @song.page_setup.copyright_line_2 = @input.read_chunk
      @song.page_setup.page_number = @input.read_chunk
    end

    def read_tempo
      @song.tempo = @input.read_chunk if @version >= 5.0
      @song.bpm = @input.read_integer
      @input.skip_byte if @version >= 5.0
    end

    def read_key
      if @version >= 4.0
        @song.key = @input.read_byte
        @input.increment_offset(3)
      else
        @song.key = @input.read_integer
      end
    end

    # TODO: Write this method
    def read_channels
      64.times do
        @input.skip_integer
        6.times { @input.skip_byte}
        @input.skip_short_integer
        @song.channels << nil
      end
    end

    # >= 5.0 only
    def read_musical_directions
      GuitarProHelper::MUSICAL_DIRECTIONS.each do |musical_direction|
        value = @input.read_short_integer
        value = nil if value == 255
        @song.musical_directions[musical_direction] = value
      end
    end

    def read_bars_settings(count)
      count.times do |i|
        bars_settings = @song.add_bar_settings
        
        bits = @input.read_bitmask
        has_new_time_signature_numerator = bits[0]
        has_new_time_signature_denominator = bits[1]
        bars_settings.has_start_of_repeat = bits[2]
        bars_settings.has_end_of_repeat = bits[3]
        has_alternate_endings = bits[4]
        has_marker = bits[5]
        has_new_key_signature = bits[6]
        bars_settings.double_bar = bits[7]

        time_signature_numerator = @input.read_byte if has_new_time_signature_numerator
        time_signature_denominator = @input.read_byte if has_new_time_signature_denominator
        beam_eight_notes_by_values = []

        if bars_settings.has_end_of_repeat
          bars_settings.repeats_count = @input.read_byte 

          # Version 5 of the format has slightly different counting for repeats
          bars_settings.repeats_count = bars_settings.repeats_count - 1 if @version >= 5.0
        end

        # Read number of alternate ending and marker
        # Their order differs depending on Guitar Pro version
        if @version < 5.0
          read_alternate_endings(bars_settings) if has_alternate_endings
          read_marker(bars_settings) if has_marker
        else
          read_marker(bars_settings) if has_marker
          read_alternate_endings(bars_settings) if has_alternate_endings
        end

        # Read new key signature if it changed
        if has_new_key_signature
          key = @input.read_byte
          scale = @input.read_boolean ? :minor : :major
          bars_settings.set_new_key_signature(key, scale)
        end

        # Read specific Guitar Pro 5 data
        if @version >= 5.0
          # Read beaming 8th notes by values if there is new time signature
          if has_new_time_signature_numerator || has_new_time_signature_denominator
            4.times { beam_eight_notes_by_values << @input.read_byte }
          end

          # If a GP5 file doesn't define an alternate ending here, ignore a byte of padding
          @input.skip_byte unless has_alternate_endings
          
          # Read triplet feel
          bars_settings.triplet_feel = GuitarProHelper::TRIPLET_FEEL[@input.read_byte]
          @song.triplet_feel = true if bars_settings.triplet_feel
          
          # Skip byte of padding
          @input.skip_byte
        end

        bars_settings.set_new_time_signature(time_signature_numerator, time_signature_denominator, beam_eight_notes_by_values) if has_new_time_signature_numerator || has_new_time_signature_denominator
      end
    end

    def read_alternate_endings(bars_settings)
      # In Guitar Pro 5 values is bitmask for creating array of alternate endings
      # Bit 0 - alt. ending #1
      # Bit 1 - alt. ending #2
      # ...
      # Bit 7 - alt. ending #8
      #
      # In Guitar Pro 4 and less value is a digit.
      if (@version >= 5.0)
        bits = @input.read_bitmask
        bits.count.times { |i| bars_settings.alternate_endings << (i+1) if bits[i] }
      else
          bars_settings.alternate_endings << @input.read_byte
      end
    end

    def read_marker(bars_settings)
      name = @input.read_chunk
      color = []
      3.times { color << @input.read_byte }
      bars_settings.set_marker(name, color)      
      @input.skip_byte
    end

    def read_tracks(count)
      count.times do |i|
        @song.tracks << Track.new(@input, @version, i)
      end

      # Padding
      @input.skip_byte if @version >= 5.0
    end

    def read_beats
      @song.bars_settings.each do |bar_settings| 
        @song.tracks.each do |track|
          
          bar = Bar.new(@version, bar_settings)

          bar.voices.count.times do |voice_number|
            beats_count = @input.read_integer
            beats_count.times do
              beat = Beat.new(@input, @version, track)
              bar.voices.fetch(VOICES.fetch(voice_number)) << beat
            end
          end

          track.bars << bar

          # Padding
          @input.skip_byte if @version >= 5.0
        end
      end
    end

  end

end