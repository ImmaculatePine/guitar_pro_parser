require 'guitar_pro_parser/io/input_stream'
require 'guitar_pro_parser/guitar_pro_helper'

module GuitarProParser

  class Reader

    def initialize(song, file_path, headers_only)
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

      if headers_only
        bars_count.times { @song.add_bar_settings }
        tracks_count.times { @song.add_track }
        return
      end

      bars_count.times { read_bars_settings }
      tracks_count.times { read_track }
      @input.skip_byte if @version >= 5.0
      
      @song.bars_settings.each do |bar_settings| 
        @song.tracks.each do |track|
          bar = Bar.new

          voices_count = @version >= 5.0 ? 2 : 1

          voices_count.times do |voice_number|
            voice = GuitarProHelper::VOICES.fetch(voice_number)
            beats_count = @input.read_integer
            beats_count.times { read_beat(track, bar, voice) }
          end

          track.bars << bar

          # Padding
          @input.skip_byte if @version >= 5.0
        end
      end
    end

    private

    def read_version
      length = @input.read_byte
      version_string = @input.read_string length
      # TODO: Raise exception for unsupported or wrong versions here
      @version = GuitarProHelper::VERSIONS.fetch(version_string)
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
      bits = @input.read_bitmask
      @song.page_setup.displayed_fields << :title if bits[0]
      @song.page_setup.displayed_fields << :subtitle if bits[1]
      @song.page_setup.displayed_fields << :artist if bits[2]
      @song.page_setup.displayed_fields << :album if bits[3]
      @song.page_setup.displayed_fields << :lyrics_author if bits[4]
      @song.page_setup.displayed_fields << :music_author if bits[5]
      @song.page_setup.displayed_fields << :lyrics_and_music_author if bits[6]
      @song.page_setup.displayed_fields << :copyright if bits[7]

      bits = @input.read_bitmask
      @song.page_setup.displayed_fields << :page_number if bits[0]

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

    def read_channels
      4.times do
        @song.channels << []
        16.times do
          channel = Channel.new
          channel.instrument = @input.read_integer
          channel.volume = @input.read_byte
          channel.pan = @input.read_byte
          channel.chorus = @input.read_byte
          channel.reverb = @input.read_byte
          channel.phaser = @input.read_byte
          channel.tremolo = @input.read_byte
          @song.channels.last << channel
          @input.skip_short_integer # Padding
        end
      end
    end

    # >= 5.0 only
    def read_musical_directions
      GuitarProHelper::MUSICAL_DIRECTIONS.each do |musical_direction|
        value = @input.read_short_integer
        value = nil if value == 0xFFFF
        @song.musical_directions[musical_direction] = value
      end
    end

    def read_bars_settings
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

    def read_track
      track = @song.add_track
      
      # Bit 0 (LSB):  Drums track
      # Bit 1:        12 stringed guitar track
      # Bit 2:        Banjo track
      # Bit 3:        Blank bit
      # Bit 4:        Marked for solo playback
      # Bit 5:        Marked for muted playback
      # Bit 6:        Use RSE playback (track instrument option)
      # Bit 7:        Indicate tuning on the score (track properties)
      bits = @input.read_bitmask
      track.drums = bits[0]
      track.twelve_stringed_guitar = bits[1]
      track.banjo = bits[2]
      track.solo_playback = bits[4]
      track.mute_playback = bits[5]
      track.rse_playback = bits[6]
      track.indicate_tuning = bits[7]

      track_name_field_length = 41
      length = @input.read_byte
      track.name = @input.read_string length
      @input.increment_offset (track_name_field_length - length - 1)

      strings_count = @input.read_integer
      track.strings.clear
      strings_count.times { track.strings << (GuitarProHelper.digit_to_note(@input.read_integer)) }
      # Skip padding if there are less than 7 strings
      (7 - strings_count).times { @input.skip_integer }

      track.midi_port = @input.read_integer
      track.midi_channel = @input.read_integer
      track.midi_channel_for_effects = @input.read_integer
      track.frets_count = @input.read_integer
      track.capo = @input.read_integer

      track.color.clear
      3.times { track.color << @input.read_byte }
      @input.skip_byte

      if @version > 5.0
        # The track properties 1 bitmask declares various options in track properties:
        # Bit 0 (LSB):  Unknown (something to do with tablature notation being enabled)
        # Bit 1:        Unknown
        # Bit 2:        Diagrams/chords below the standard notation
        # Bit 3:        Show rhythm with tab
        # Bit 4:        Force horizontal beams
        # Bit 5:        Force channels 11 to 16
        # Bit 6:        Diagrams list on top of the score
        # Bit 7 (MSB):  Diagrams in the score
        bits = @input.read_bitmask
        track.diagrams_below_the_standard_notation = bits[2]
        track.show_rythm_with_tab = bits[3]
        track.force_horizontal_beams = bits[4]
        track.force_channels_11_to_16 = bits[5]
        track.diagrams_list_on_top_of_score = bits[6]
        track.diagrams_in_the_score = bits[7]

        # The track properties 2 bitmask declares various options in track properties/instrument:
        # Bit 0 (LSB):  Unknown
        # Bit 1:        Auto-Let Ring
        # Bit 2:        Auto Brush
        # Bit 3:        Extend rhythmic inside the tab
        # Bits 4-7:     Unknown
        bits = @input.read_bitmask
        track.auto_let_ring = bits[1]
        track.auto_brush = bits[2]
        track.extend_rhytmic_inside_the_tab = bits[3]

        @input.skip_byte
        track.midi_bank = @input.read_byte
        track.human_playing = @input.read_byte
        track.auto_accentuation = @input.read_byte
        @input.increment_offset 31
        track.sound_bank = @input.read_byte
        @input.increment_offset 7

        track.equalizer.clear
        4.times { track.equalizer << @input.read_byte }

        track.instrument_effect_1 = @input.read_chunk
        track.instrument_effect_2 = @input.read_chunk
      end

      @input.increment_offset 45 if @version == 5.0
    end

    def read_beat(track, bar, voice)
      beat = Beat.new
      bar.voices.fetch(voice) << beat

      # The beat bitmask declares which parameters are defined for the beat:
      # Bit 0 (LSB):  Dotted note
      # Bit 1:        Chord diagram present
      # Bit 2:        Text present
      # Bit 3:        Beat effects present
      # Bit 4:        Mix table change present
      # Bit 5:        This beat is an N-tuplet
      # Bit 6:        Is a rest beat
      # Bit 7 (MSB):  Unused (set to 0)
      bits = @input.read_bitmask
      beat.dotted = bits[0]
      has_chord_diagram = bits[1]
      has_text = bits[2]
      has_effects = bits[3]
      has_mix_table_change = bits[4]
      is_tuplet = bits[5]
      is_rest = bits[6]

      beat.rest = GuitarProHelper::REST_TYPES.fetch(@input.read_byte.to_s) if is_rest
      beat.duration = GuitarProHelper::DURATIONS.fetch(@input.read_signed_byte.to_s)
      beat.tuplet = @input.read_integer if is_tuplet
      read_chord_diagram(beat, track.strings.count) if has_chord_diagram
      beat.text = @input.read_chunk if has_text
      read_beat_effects(beat) if has_effects
      read_mix_table(beat) if has_mix_table_change 
      
      strings_bitmask = @input.read_bitmask
      used_strings = []
      (0..6).to_a.reverse.each { |i| used_strings << strings_bitmask[i] }
      7.times do |i|
        if used_strings[i]
          note = Note.new
          read_note(note)
          beat.strings["#{i+1}"] = note
        end
      end

      # Transponse data in Guitar Pro 5
      if @version >= 5.0
        # Bits 0-3: Unknown/unused
        # Bit 4:    8va (up one octave)
        # Bit 5:    8vb (down one octave)
        # Bit 6:    15ma (up two octaves)
        # Bit 7:    Unknown/unused
        bits1 = @input.read_bitmask

        # Bit 8:    15mb (down two octaves)
        # Bits 9-10:  Unknown/unused
        # Bit 11:   An extra unknown data byte follows this bitmask
        # Bits 12-15: Unknown/unused
        bits2 = @input.read_bitmask

        beat.transpose = '8va' if bits1[4]
        beat.transpose = '8vb' if bits1[5]
        beat.transpose = '15ma' if bits1[6]
        beat.transpose = '15mb' if bits2[0]

        # Unknown data
        @input.skip_byte if bits2[3]
      end
    end

    def read_chord_diagram(beat, strings_count)
      beat.chord_diagram = ChordDiagram.new

      format = @input.read_bitmask
      if format[0] == false # Guitar Pro 3 format
        beat.chord_diagram.name = @input.read_chunk
        beat.chord_diagram.base_fret = @input.read_integer
        unless beat.chord_diagram.base_fret.zero?
          strings_count.times { beat.chord_diagram.frets << @input.read_integer }
        end
      else # Guitar Pro 4 and 5 format
        beat.chord_diagram.display_as = @input.read_boolean ? :sharp : :flat
        @input.increment_offset(3)

        root = @input.read_byte
        beat.chord_diagram.root = GuitarProHelper::NOTES[root] unless root == 12

        beat.chord_diagram.type = GuitarProHelper::CHORD_TYPES[@input.read_byte]
        beat.chord_diagram.nine_eleven_thirteen = GuitarProHelper::NINE_ELEVEN_THIRTEEN.fetch(@input.read_byte)

        bass = @input.read_integer
        beat.chord_diagram.bass = GuitarProHelper::NOTES[bass] if bass >= 0

        beat.chord_diagram.tonality = GuitarProHelper::CHORD_TONALITIES[@input.read_integer]
        beat.chord_diagram.add = @input.read_boolean

        name_length = @input.read_byte
        beat.chord_diagram.name = @input.read_string(name_length)
        @input.increment_offset(20 - name_length) if name_length < 20

        @input.increment_offset(2)
        beat.chord_diagram.fifth_tonality = GuitarProHelper::CHORD_TONALITIES[@input.read_byte]
        beat.chord_diagram.ninth_tonality = GuitarProHelper::CHORD_TONALITIES[@input.read_byte]
        beat.chord_diagram.eleventh_tonality = GuitarProHelper::CHORD_TONALITIES[@input.read_byte]

        beat.chord_diagram.base_fret = @input.read_integer

        strings_count.times { beat.chord_diagram.frets << @input.read_integer }        
        (7 - strings_count).times { @input.skip_integer }

        barres_count = @input.read_byte
        barres_frets = []
        barres_starts = []
        barres_ends = []
        5.times { barres_frets << @input.read_byte }
        5.times { barres_starts << @input.read_byte }
        5.times { barres_ends << @input.read_byte }
        barres_count.times do |i| 
          beat.chord_diagram.add_barre(barres_frets[i],
                                       barres_starts[i],
                                       barres_ends[i])
        end

        # TODO: I don't know why but it looks inverted
        beat.chord_diagram.intervals << 1 if @input.read_byte == 0x01
        beat.chord_diagram.intervals << 3 if @input.read_byte == 0x01
        beat.chord_diagram.intervals << 5 if @input.read_byte == 0x01
        beat.chord_diagram.intervals << 7 if @input.read_byte == 0x01
        beat.chord_diagram.intervals << 9 if @input.read_byte == 0x01
        beat.chord_diagram.intervals << 11 if @input.read_byte == 0x01
        beat.chord_diagram.intervals << 13 if @input.read_byte == 0x01
        @input.skip_byte

        strings_count.times do |i|
          finger_id = @input.read_signed_byte
          finger = nil
          if finger_id == -2
            finger = :unknown
          elsif finger_id == -1
            finger = :no
          else
            finger = GuitarProHelper::FINGERS[finger_id]
          end
          beat.chord_diagram.fingers << finger
        end
        @input.increment_offset(7 - strings_count) if strings_count < 7

        beat.chord_diagram.display_fingering = @input.read_boolean
      end
    end

    def read_beat_effects(beat)
      # The beat effects bitmasks declare which parameters are defined for the beat:
      # Byte 1
      #  Bit 0:     Vibrato
      #  Bit 1:     Wide vibrato
      #  Bit 2:     Natural harmonic
      #  Bit 3:     Artificial harmonic
      #  Bit 4:     Fade in
      #  Bit 5:     String effect
      #  Bit 6:     Stroke effect
      #  Bit 7:     Unused (set to 0)
      bits = @input.read_bitmask
      beat.add_effect(:vibrato) if bits[0]
      beat.add_effect(:wide_vibrato) if bits[1]
      beat.add_effect(:natural_harmonic) if bits[2]
      beat.add_effect(:artificial_harmonic) if bits[3]
      beat.add_effect(:fade_in) if bits[4]
      beat.add_effect(:string_effect) if bits[5]
      beat.add_effect(:stroke_effect) if bits[6]

      # Byte 2 (extended beat effects, only if the major file version is >= 4):
      #  Bit 0:     Rasguedo
      #  Bit 1:     Pickstroke
      #  Bit 2:     Tremolo bar
      #  Bits 3-7:  Unused (set to 0)
      if @version >= 4.0
        bits = @input.read_bitmask
        beat.add_effect(:rasguedo) if bits[0]
        beat.add_effect(:pickstroke) if bits[1]
        beat.add_effect(:tremolo_bar) if bits[2]
      end

      if beat.has_effect? :string_effect
        beat.effects[:string_effect] = GuitarProHelper::STRING_EFFECTS.fetch(@input.read_byte)
        # Skip a value applied to the string effect in old Guitar Pro versions
        @input.read_integer if @version < 4.0
      end

      beat.effects[:tremolo_bar] = read_bend if beat.has_effect? :tremolo_bar

      if beat.has_effect? :stroke_effect
        upstroke = GuitarProHelper::STROKE_EFFECT_SPEEDS.fetch(@input.read_byte)
        downstroke = GuitarProHelper::STROKE_EFFECT_SPEEDS.fetch(@input.read_byte)
        beat.effects[:stroke_effect] = { upstroke_speed: upstroke, downstroke_speed: downstroke }
      end

      beat.effects[:pickstroke] = GuitarProHelper::STROKE_DIRECTIONS.fetch(@input.read_byte) if beat.has_effect? :pickstroke
    end

    def read_bend
      type = GuitarProHelper::BEND_TYPES.fetch(@input.read_byte)
      height = @input.read_integer
      points_coint = @input.read_integer
      result = { type: type, height: height, points: [] }
      points_coint.times do
        time = @input.read_integer
        pitch_alteration = @input.read_integer
        vibrato_type = GuitarProHelper::BEND_VIBRATO_TYPES.fetch(@input.read_byte)
        result[:points] << { time: time, pitch_alteration: pitch_alteration, vibrato_type: vibrato_type }
      end

      result
    end

    # TODO: It seems that this method is incorrect. Test it.
    def read_mix_table(beat)
      beat.mix_table = {}

      instrument = @input.read_signed_byte
      beat.mix_table[:instrument] = instrument unless instrument == -1

      if @version >= 5.0
        # RSE related 4 digit numbers (-1 if RSE is disabled)
        3.times { @input.skip_integer }
        @input.skip_integer # Padding
      end

      volume = @input.read_signed_byte
      pan = @input.read_signed_byte
      chorus = @input.read_signed_byte
      reverb = @input.read_signed_byte
      phaser = @input.read_signed_byte
      tremolo = @input.read_signed_byte
      
      tempo_string = ''
      tempo_string = @input.read_chunk if @version >= 5.0
      tempo = @input.read_integer

      beat.mix_table[:volume] = { value: volume, transition: @input.read_byte } if volume >= 0
      beat.mix_table[:pan] = { value: pan, transition: @input.read_byte } if pan >= 0
      beat.mix_table[:chorus] = { value: chorus, transition: @input.read_byte } if chorus >= 0
      beat.mix_table[:reverb] = { value: reverb, transition: @input.read_byte } if reverb >= 0
      beat.mix_table[:phaser] = { value: phaser, transition: @input.read_byte } if phaser >= 0
      beat.mix_table[:tremolo] = { value: tremolo, transition: @input.read_byte } if tremolo >= 0

      if tempo >= 0
        beat.mix_table[:tempo] = { value: tempo, transition: @input.read_byte, text: tempo_string }
        beat.mix_table[:tempo][:hidden_text] = @input.read_byte if @version > 5.0
      end
      
      # The mix table change applied tracks bitmask declares which mix change events apply to all tracks (set = all tracks, reset = current track only):
      # Bit 0 (LSB):  Volume change
      # Bit 1:    Pan change
      # Bit 2:    Chorus change
      # Bit 3:    Reverb change
      # Bit 4:    Phaser change
      # Bit 5:    Tremolo change
      # Bits 6-7: Unused
      if @version >= 4.0
        bits = @input.read_bitmask
        apply_hash = { true => :all, false => :current }
        beat.mix_table[:volume][:apply_to] = apply_hash[bits[0]] unless beat.mix_table[:volume].nil?
        beat.mix_table[:pan][:apply_to] = apply_hash[bits[1]] unless beat.mix_table[:pan].nil?
        beat.mix_table[:chorus][:apply_to] = apply_hash[bits[2]] unless beat.mix_table[:chorus].nil?
        beat.mix_table[:reverb][:apply_to] = apply_hash[bits[3]] unless beat.mix_table[:reverb].nil?
        beat.mix_table[:phaser][:apply_to] = apply_hash[bits[4]] unless beat.mix_table[:phaser].nil?
        beat.mix_table[:tremolo][:apply_to] = apply_hash[bits[5]] unless beat.mix_table[:tremolo].nil?
      end

      # Padding
      @input.skip_byte if @version >= 5.0
      
      if @version > 5.0
        rse_effect_2 = @input.read_chunk
        rse_effect_1 = @input.read_chunk

        beat.mix_table[:rse_effect_2] = rse_effect_2 unless rse_effect_2.empty?
        beat.mix_table[:rse_effect_1] = rse_effect_1 unless rse_effect_1.empty?
      end
    end

    def read_note(note)
      # The note bitmask declares which parameters are defined for the note:
      # Bit 0 (LSB):  Time-independent duration
      # Bit 1:    Heavy Accentuated note
      # Bit 2:    Ghost note
      # Bit 3:    Note effects present
      # Bit 4:    Note dynamic
      # Bit 5:    Note type
      # Bit 6:    Accentuated note
      # Bit 7:    Right/Left hand fingering
      bits = @input.read_bitmask
      
      # TODO: Find in Guitar Pro how to enable this feature
      note.time_independent_duration = bits[0]

      # Guitar Pro 5 files has 'Heavy accentuated' (bit 1) and 'Accentuated' (bit 6) states.
      # Guitar Pro 4 and less have only 'Accentuated' (bit 6) state.
      # So the only supported option for note is just 'Accentuated'.
      note.accentuated = bits[1] || bits[6]

      note.ghost = bits[2]

      has_effects = bits[3]
      has_dynamic = bits[4]
      has_type = bits[5]
      has_fingering = bits[7]

      note.type = GuitarProHelper::NOTE_TYPES.fetch(@input.read_byte - 1) if has_type

      # Ignore time-independed duration data for Guitar Pro 4 and less
      @input.skip_short_integer if @version < 5.0 && note.time_independent_duration

      note.dynamic = GuitarProHelper::NOTE_DYNAMICS.fetch(@input.read_byte - 1) if has_dynamic
      note.fret = @input.read_byte

      if has_fingering
        left_finger = @input.read_signed_byte
        right_finger = @input.read_signed_byte

        note.add_left_hand_finger(GuitarProHelper::FINGERS.fetch(left_finger)) unless left_finger == -1
        note.add_right_hand_finger(GuitarProHelper::FINGERS.fetch(right_finger)) unless right_finger == -1
      end

      # Ignore time-independed duration data for Guitar Pro 5
      @input.increment_offset 8 if @version >= 5.0 && note.time_independent_duration

      # Skip padding
      @input.skip_byte if @version >= 5.0

      if has_effects
        # The note effect 1 bitmask declares which effects are defined for the note:
        # Bit 0 (LSB):  Bend present
        # Bit 1:    Hammer on/Pull off from the current note
        # Bit 2:    Slide from the current note (GP3 format version)
        # Bit 3:    Let ring
        # Bit 4:    Grace note
        # Bits 5-7: Unused (set to 0)
        bits = @input.read_bitmask
        has_bend = bits[0]
        hammer_or_pull = bits[1]
        has_slide = bits[2]
        let_ring = bits[3]
        has_grace = bits[4]

        note.hammer_or_pull = hammer_or_pull
        note.let_ring = let_ring

        has_tremolo = false
        has_slide = false
        has_harmonic = false
        has_trill = false

        if @version >= 4.0
          # The note effect 2 bitmask declares more effects for the note:
          # Bit 0 (LSB):  Note played staccato
          # Bit 1:    Palm Mute
          # Bit 2:    Tremolo Picking
          # Bit 3:    Slide from the current note
          # Bit 4:    Harmonic note
          # Bit 5:    Trill
          # Bit 6:    Vibrato
          # Bit 7 (MSB):  Unused (set to 0)
          bits = @input.read_bitmask
          staccato = bits[0]
          palm_mute = bits[1]
          has_tremolo = bits[2]
          has_slide = bits[3]
          has_harmonic = bits[4]
          has_trill = bits[5]
          vibrato = bits[6]

          note.staccato = staccato
          note.palm_mute = palm_mute
          note.vibrato = vibrato
        end

        note.bend = read_bend if has_bend

        read_grace(note) if has_grace
        note.add_tremolo(GuitarProHelper::TREMOLO_PICKING_SPEEDS.fetch(@input.read_byte.to_s)) if has_tremolo

        if has_slide
          value = @input.read_signed_byte.to_s
          if @version >= 5.0
            note.slide = GuitarProHelper::SLIDE_TYPES.fetch(GuitarProHelper::MAP_SLIDE_TYPES_GP5.fetch(value))
          else
            note.slide = GuitarProHelper::SLIDE_TYPES.fetch(GuitarProHelper::MAP_SLIDE_TYPES_GP4.fetch(value))
          end
        end

        read_harmonic(note) if has_harmonic

        if has_trill
          fret = @input.read_byte
          period = GuitarProHelper::TRILL_PERIODS.fetch(@input.read_byte.to_s)
          note.add_trill(fret, period)
        end
      end
    end

    def read_grace(note)
      fret = @input.read_byte
      dynamic = GuitarProHelper::NOTE_DYNAMICS.fetch(@input.read_byte - 1)
      transition = GuitarProHelper::GRACE_NOTE_TRANSITION_TYPES.fetch(@input.read_byte)
      duration = GuitarProHelper::GRACE_NOTE_DURATIONS.fetch(@input.read_byte.to_s)
      dead = false
      position = :before_the_beat

      if @version >= 5.0
        bits = @input.read_bitmask
        dead = bits[0]
        position = :on_the_beat if bits[1]
      end

      note.add_grace(fret, dynamic, transition, duration, dead, position)
    end

    def read_harmonic(note)
      type = nil
      harmonic_type_index = @input.read_byte
      if @version >= 5.0
        type = GuitarProHelper::HARMONIC_TYPES.fetch(harmonic_type_index)
      else
        map_of_gp4_harmonics = { '0' => 0,
                                 '1' => 1,
                                 '15' => 2,
                                 '17' => 2,
                                 '22' => 2,
                                 '3' => 3,
                                 '4' => 4,
                                 '5' => 5 }
        type = GuitarProHelper::HARMONIC_TYPES.fetch(map_of_gp4_harmonics[harmonic_type_index.to_s])
      end
      
      note.add_harmonic(type)

      # Guitar Pro 5 has additional data about artificial and tapped harmonics
      # But Guitar Pro 4 and less have not this data so we'll skip it now
      if @version >= 5.0
        case type
        when :artificial
          # Note (1 byte), note type (1 byte) and harmonic octave (1 byte)
          # E.g. C# 15ma
          @input.increment_offset(3)
        when :tapped
          # Tapped fret (1 byte)
          @input.skip_byte
        end
      end
    end

  end

end