module GuitarProParser

  # Creates Guitar Pro file of version 5.10
  #
  class GP5Writer

    def initialize(song, file_name)
      @song = song
      @output = GuitarProParser::OutputStream.new(file_name)

      write_version
      write_info
      write_notices
      write_lyrics
      @output.write_signed_integer(@song.master_volume)
      @output.write_padding(4)
      @song.equalizer.each { |eq| @output.write_byte(eq) }
      write_page_setup
      write_tempo
      write_key
      @output.write_byte(@song.octave)
      write_channels
      write_musical_directions
      @output.write_signed_integer(@song.master_reverb)

      @output.write_signed_integer(@song.bars_settings.count)
      @output.write_signed_integer(@song.tracks.count)

      @song.bars_settings.each { |bar_settings| write_bar_settings(bar_settings) }
      @song.tracks.each { |track| write_track(track) }
      @output.write_padding(1)

      @song.bars_settings.count.times do |bar_index|
        @song.tracks.each do |track|
          bar = track.bars[bar_index]

          # Write 2 voices
          2.times do |voice_number|
            voice = GuitarProHelper::VOICES.fetch(voice_number)
            @output.write_signed_integer(bar.voices[voice].count)
            bar.voices[voice].each { |beat| write_beat(beat) }
          end

          @output.write_padding(1)
        end
      end

      @output.close
    end
    
    def write_version
      version = 'FICHIER GUITAR PRO v5.10'
      length = version.length
      @output.write_byte(length)
      @output.write_string(version)
      @output.write_padding(31 - length - 1)
    end

    def write_info
      @output.write_chunk(@song.title)
      @output.write_chunk(@song.subtitle)
      @output.write_chunk(@song.artist)
      @output.write_chunk(@song.album)
      @output.write_chunk(@song.lyricist)
      @output.write_chunk(@song.composer)
      @output.write_chunk(@song.copyright)
      @output.write_chunk(@song.transcriber)
      @output.write_chunk(@song.instructions)
    end

    def write_notices
      notices = @song.notices.split('/n')
      @output.write_signed_integer(notices.count)
      notices.each { |notice| @output.write_chunk(notice) }
    end

    def write_lyrics
      @output.write_signed_integer(@song.lyrics_track)

      @song.lyrics.each do |lyric|
        @output.write_signed_integer(lyric.fetch(:bar))
        text = lyric.fetch(:text)
        @output.write_signed_integer(text.length)
        @output.write_string(text)
      end
    end

    def write_page_setup
      @output.write_signed_integer(@song.page_setup.page_format_length)
      @output.write_signed_integer(@song.page_setup.page_format_width)
      @output.write_signed_integer(@song.page_setup.left_margin)
      @output.write_signed_integer(@song.page_setup.right_margin)
      @output.write_signed_integer(@song.page_setup.top_margin)
      @output.write_signed_integer(@song.page_setup.bottom_margin)
      @output.write_signed_integer(@song.page_setup.score_size)

      bits = Array.new(8, false)
      bits[0] = true if @song.page_setup.displayed_fields.include? :title
      bits[1] = true if @song.page_setup.displayed_fields.include? :subtitle
      bits[2] = true if @song.page_setup.displayed_fields.include? :artist
      bits[3] = true if @song.page_setup.displayed_fields.include? :album
      bits[4] = true if @song.page_setup.displayed_fields.include? :lyrics_author
      bits[5] = true if @song.page_setup.displayed_fields.include? :music_author
      bits[6] = true if @song.page_setup.displayed_fields.include? :lyrics_and_music_author
      bits[7] = true if @song.page_setup.displayed_fields.include? :copyright
      @output.write_bitmask(bits)

      bits = Array.new(8, false)
      bits[0] = true if @song.page_setup.displayed_fields.include? :page_number
      @output.write_bitmask(bits)
      
      @output.write_chunk(@song.page_setup.title)
      @output.write_chunk(@song.page_setup.subtitle)
      @output.write_chunk(@song.page_setup.artist)
      @output.write_chunk(@song.page_setup.album)
      @output.write_chunk(@song.page_setup.lyrics_author)
      @output.write_chunk(@song.page_setup.music_author)
      @output.write_chunk(@song.page_setup.lyrics_and_music_author)
      @output.write_chunk(@song.page_setup.copyright_line_1)
      @output.write_chunk(@song.page_setup.copyright_line_2)
      @output.write_chunk(@song.page_setup.page_number)
    end

    def write_tempo
      @output.write_chunk(@song.tempo)
      @output.write_signed_integer(@song.bpm)
      @output.write_padding(1)
    end

    def write_key
      @output.write_byte(@song.key)
      @output.write_padding(3)
    end

    def write_channels
      @song.channels.each do |port|
        port.each do |channel|
          @output.write_signed_integer(channel.instrument)
          @output.write_byte(channel.volume)
          @output.write_byte(channel.pan)
          @output.write_byte(channel.chorus)
          @output.write_byte(channel.reverb)
          @output.write_byte(channel.phaser)
          @output.write_byte(channel.tremolo)
          @output.write_padding(2)
        end
      end
    end

    def write_musical_directions
      GuitarProHelper::MUSICAL_DIRECTIONS.each do |musical_direction|
        value = @song.musical_directions[musical_direction]
        value = 0xFFFF if value.nil?
        @output.write_short_integer(value)
      end
    end

    def write_bar_settings(bar_settings)
      bits = Array.new(8, false)

      unless bar_settings.new_time_signature.nil?
        bits[0] = true unless bar_settings.new_time_signature[:numerator].nil?
        bits[1] = true unless bar_settings.new_time_signature[:denominator].nil?
      end
      bits[2] = true if bar_settings.has_start_of_repeat
      bits[3] = true if bar_settings.has_end_of_repeat
      bits[4] = true unless bar_settings.alternate_endings.empty?
      bits[5] = true unless bar_settings.marker.nil?
      bits[6] = true unless bar_settings.new_key_signature.nil?
      bits[7] = bar_settings.double_bar      
      @output.write_bitmask(bits)

      @output.write_byte(bar_settings.new_time_signature[:numerator]) if bits[0]
      @output.write_byte(bar_settings.new_time_signature[:denominator]) if bits[1]
      @output.write_byte(bar_settings.repeats_count + 1) if bits[3]

      if bits[5]
        @output.write_chunk(bar_settings.marker[:name])
        @output.write_byte(bar_settings.marker[:color][0])
        @output.write_byte(bar_settings.marker[:color][1])
        @output.write_byte(bar_settings.marker[:color][2])
        @output.write_padding(1)
      end

      if bits[4]
        alt_bits = Array.new(8, false)
        8.times { |i| alt_bits[i] = true if bar_settings.alternate_endings.include? (i+1) }
        @output.write_bitmask(alt_bits)
      end

      if bits[6]
        @output.write_byte(bar_settings.new_key_signature[:key])
        @output.write_boolean(bar_settings.new_key_signature[:scale] == :minor)
      end

      if bits[0] || bits[1]
        bar_settings.new_time_signature[:beam_eight_notes_by_values].each do |value|
          @output.write_byte(value)
        end
      end

      @output.write_padding(1) unless bits[4]
      @output.write_byte(GuitarProHelper::TRIPLET_FEEL.index(bar_settings.triplet_feel))
      @output.write_padding(1)
    end

    def write_track(track)
      bits = Array.new(8, false)
      bits[0] = track.drums
      bits[1] = track.twelve_stringed_guitar
      bits[2] = track.banjo
      bits[4] = track.solo_playback
      bits[5] = track.mute_playback
      bits[6] = track.rse_playback
      bits[7] = track.indicate_tuning
      @output.write_bitmask(bits)

      @output.write_byte(track.name.length)
      @output.write_string(track.name)
      @output.write_padding(41 - track.name.length - 1)
      
      @output.write_signed_integer(track.strings.count)
      track.strings.each do |string|
        @output.write_signed_integer(GuitarProHelper.note_to_digit(string))
      end
      padding = (7 - track.strings.count) * 4
      @output.write_padding(padding) if padding > 0

      @output.write_signed_integer(track.midi_port)
      @output.write_signed_integer(track.midi_channel)
      @output.write_signed_integer(track.midi_channel_for_effects)
      @output.write_signed_integer(track.frets_count)
      @output.write_signed_integer(track.capo)
      
      @output.write_byte(track.color[0])
      @output.write_byte(track.color[1])
      @output.write_byte(track.color[2])
      @output.write_padding(1)
      
      bits = Array.new(8, false)
      bits[2] = track.diagrams_below_the_standard_notation
      bits[3] = track.show_rythm_with_tab
      bits[4] = track.force_horizontal_beams
      bits[5] = track.force_channels_11_to_16
      bits[6] = track.diagrams_list_on_top_of_score
      bits[7] = track.diagrams_in_the_score
      @output.write_bitmask(bits)

      bits = Array.new(8, false)
      bits[1] = track.auto_let_ring
      bits[2] = track.auto_brush
      bits[3] = track.extend_rhytmic_inside_the_tab
      @output.write_bitmask(bits)
      
      @output.write_padding(1)
      @output.write_byte(track.midi_bank)
      @output.write_byte(track.human_playing)
      @output.write_byte(track.auto_accentuation)
      @output.write_padding(31)
      @output.write_byte(track.sound_bank)
      @output.write_padding(7)

      track.equalizer.each { |eq| @output.write_byte(eq) }

      @output.write_chunk(track.instrument_effect_1)
      @output.write_chunk(track.instrument_effect_2)
    end

    def write_beat(beat)
      bits = Array.new(8, false)
      bits[0] = beat.dotted
      bits[1] = !beat.chord_diagram.nil?
      bits[2] = !beat.text.nil?
      bits[3] = !beat.effects.empty?
      bits[4] = !beat.mix_table.nil?
      bits[5] = !beat.tuplet.nil?
      bits[6] = !beat.rest.nil?
      @output.write_bitmask(bits)

      @output.write_byte(GuitarProHelper::REST_TYPES.key(beat.rest).to_i) if bits[6]
      @output.write_signed_byte(GuitarProHelper::DURATIONS.key(beat.duration).to_i)
      @output.write_signed_integer(beat.tuplet) if bits[5]
      write_chord_diagram(beat.chord_diagram) if bits[1]
      @output.write_chunk(beat.text) if bits[2]
      write_beat_effects(beat.effects) if bits[3]
      write_mix_table(beat.mix_table) if bits[4]

      bits = Array.new(8, false)
      # beat.strings.each { |string, _| bits[string.to_i - 1] = true }
      @output.write_bitmask(bits.reverse)
      # beat.string.each { |_, note| write_note(note) }
      
      bits1 = Array.new(8, false)
      bits2 = Array.new(8, false)

      bits1[4] = true if beat.transpose == '8va'
      bits1[5] = true if beat.transpose == '8vb'
      bits1[6] = true if beat.transpose == '15ma'
      bits2[0] = true if beat.transpose == '15mb'
      bits2[3] = true if beat.extra_byte_after_transpose

      @output.write_bitmask(bits1)  
      @output.write_bitmask(bits2)
      @output.write_padding(1) if bits2[3]
    end

    def write_chord_diagram(chord_diagram)
      # Write format of GP4/5
      @output.write_byte(1)

      @output.write_boolean(chord_diagram.display_as == :sharp)
      @output.write_padding(3)

      if chord_diagram.root.nil?
        @output.write_byte(12)
      else
        @output.write_byte(GuitarProHelper::NOTES.index(chord_diagram.root))
      end

      @output.write_byte(GuitarProHelper::CHORD_TYPES.index(chord_diagram.type))
      @output.write_byte(GuitarProHelper::NINE_ELEVEN_THIRTEEN.index(chord_diagram.nine_eleven_thirteen))

      if chord_diagram.bass.nil?
        @output.write_signed_integer(-1)
      else
        @output.write_signed_integer(GuitarProHelper::NOTES.index(chord_diagram.bass))
      end

      @output.write_signed_integer(GuitarProHelper::CHORD_TONALITIES.index(chord_diagram.tonality))
      @output.write_boolean(chord_diagram.add)
      
      @output.write_byte(chord_diagram.name.length)
      @output.write_string(chord_diagram.name)
      @output.write_padding(20 - chord_diagram.name.length) if chord_diagram.name.length < 20

      @output.write_padding(2)
      @output.write_byte(GuitarProHelper::CHORD_TONALITIES.index(chord_diagram.fifth_tonality))
      @output.write_byte(GuitarProHelper::CHORD_TONALITIES.index(chord_diagram.ninth_tonality))
      @output.write_byte(GuitarProHelper::CHORD_TONALITIES.index(chord_diagram.eleventh_tonality))

      @output.write_signed_integer(chord_diagram.base_fret)
      
      chord_diagram.frets.each { |fret| @output.write_signed_integer(fret) }
      (7 - chord_diagram.frets.count).times { @output.write_signed_integer(-1) }

      @output.write_byte(chord_diagram.barres.count)
      chord_diagram.barres.each { |barre| @output.write_byte(barre[:fret]) }
      (5 - chord_diagram.barres.count).times { @output.write_byte(0) }

      chord_diagram.barres.each { |barre| @output.write_byte(barre[:start_string]) }
      (5 - chord_diagram.barres.count).times { @output.write_byte(0) }

      chord_diagram.barres.each { |barre| @output.write_byte(barre[:end_string]) }
      (5 - chord_diagram.barres.count).times { @output.write_byte(0) }
      
      @output.write_boolean(chord_diagram.intervals.include? 1)
      @output.write_boolean(chord_diagram.intervals.include? 3)
      @output.write_boolean(chord_diagram.intervals.include? 5)
      @output.write_boolean(chord_diagram.intervals.include? 7)
      @output.write_boolean(chord_diagram.intervals.include? 9)
      @output.write_boolean(chord_diagram.intervals.include? 11)
      @output.write_boolean(chord_diagram.intervals.include? 13)
      @output.write_padding(1)
      
      chord_diagram.fingers.each do |finger|
        finger_id = -2
        if finger == :no
          finger_id = -1
        elsif finger != :unknown
          finger_id = GuitarProHelper::FINGERS.index(finger)
        end
        @output.write_signed_byte(finger_id)
      end
      (7 - chord_diagram.fingers.count).times { @output.write_signed_byte(-2) }

      @output.write_boolean(chord_diagram.display_fingering)
    end

    def write_beat_effects(effects)
      bits = Array.new(8, false)
      bits[0] = effects.include? :vibrato
      bits[1] = effects.include? :wide_vibrato
      bits[2] = effects.include? :natural_harmonic
      bits[3] = effects.include? :artificial_harmonic
      bits[4] = effects.include? :fade_in
      bits[5] = effects.include? :string_effect
      bits[6] = effects.include? :stroke_effect
      @output.write_bitmask(bits)

      bits = Array.new(8, false)
      bits[0] = effects.include? :rasguedo
      bits[1] = effects.include? :pickstroke
      bits[2] = effects.include? :tremolo_bar
      @output.write_bitmask(bits)

      @output.write_byte(GuitarProHelper::STRING_EFFECTS.index(effects[:string_effect])) if effects.include? :string_effect
        
      write_bend(effects[:tremolo_bar]) if effects.include? :tremolo_bar
      
      if effects.include? :stroke_effect
        @output.write_byte(GuitarProHelper::STROKE_EFFECT_SPEEDS.index(effects[:stroke_effect][:upstroke_speed]))
        @output.write_byte(GuitarProHelper::STROKE_EFFECT_SPEEDS.index(effects[:stroke_effect][:downstroke_speed]))
      end

      @output.write_byte(GuitarProHelper::STROKE_DIRECTIONS.index(effects[:pickstroke])) if effects.include? :pickstroke
    end

    def write_bend(bend)
      @output.write_byte(GuitarProHelper::BEND_TYPES.index(bend[:type]))
      @output.write_signed_integer(bend[:height])
      @output.write_signed_integer(bend[:points].count)
      bend[:points].each do |point|
        @output.write_signed_integer(point[:time])
        @output.write_signed_integer(point[:pitch_alteration])
        @output.write_byte(GuitarProHelper::BEND_VIBRATO_TYPES.index(point[:vibrato_type]))
      end
    end

    def write_mix_table(mix_table)
      if mix_table[:instrument].nil?
        @output.write_signed_byte(-1)
      else
        @output.write_signed_byte(mix_table[:instrument])
      end
      
      mix_table[:rse_related_data].each { |data| @output.write_signed_integer(data) }
      @output.write_padding(4)

      volume = -1
      pan = -1
      chorus = -1
      reverb = -1
      phaser = -1
      tremolo = -1
      
      volume = mix_table[:volume][:value] if mix_table.include? :volume
      pan = mix_table[:pan][:value] if mix_table.include? :pan
      chorus = mix_table[:chorus][:value] if mix_table.include? :chorus
      reverb = mix_table[:reverb][:value] if mix_table.include? :reverb
      phaser = mix_table[:phaser][:value] if mix_table.include? :phaser
      tremolo = mix_table[:tremolo][:value] if mix_table.include? :tremolo

      @output.write_signed_byte(volume)
      @output.write_signed_byte(pan)
      @output.write_signed_byte(chorus)
      @output.write_signed_byte(reverb)
      @output.write_signed_byte(phaser)
      @output.write_signed_byte(tremolo)


      tempo_string = ''
      tempo = -1

      if mix_table.include? :tempo
        tempo_string = mix_table[:tempo][:text] 
        tempo = mix_table[:tempo][:value]
      end

      @output.write_chunk(tempo_string)
      @output.write_signed_integer(tempo)

      @output.write_byte(mix_table[:volume][:transition]) if volume >= 0
      @output.write_byte(mix_table[:pan][:transition]) if pan >= 0
      @output.write_byte(mix_table[:chorus][:transition]) if chorus >= 0
      @output.write_byte(mix_table[:reverb][:transition]) if reverb >= 0
      @output.write_byte(mix_table[:phaser][:transition]) if phaser >= 0
      @output.write_byte(mix_table[:tremolo][:transition]) if tremolo >= 0

      if tempo >= 0
        @output.write_byte(mix_table[:tempo][:transition])
        hidden_text = mix_table[:hidden_text] || 0
        @output.write_byte(hidden_text)
      end

      bits = Array.new(8, false)
      bits[0] = mix_table[:volume][:apply_to] == :all unless mix_table[:volume].nil?
      bits[1] = mix_table[:pan][:apply_to] == :all unless mix_table[:pan].nil?
      bits[2] = mix_table[:chorus][:apply_to] == :all unless mix_table[:chorus].nil?
      bits[3] = mix_table[:reverb][:apply_to] == :all unless mix_table[:reverb].nil?
      bits[4] = mix_table[:phaser][:apply_to] == :all unless mix_table[:phaser].nil?
      bits[5] = mix_table[:tremolo][:apply_to] == :all unless mix_table[:tremolo].nil?
      @output.write_bitmask(bits)
      
      @output.write_padding(1)

      @output.write_chunk(mix_table[:rse_effect_2] || '')
      @output.write_chunk(mix_table[:rse_effect_1] || '')
    end

    def write_note(note)
      
    end

  end

end