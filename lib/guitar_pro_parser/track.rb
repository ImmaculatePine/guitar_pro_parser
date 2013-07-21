require "guitar_pro_parser/parser"
require "guitar_pro_parser/guitar_pro_helper"

module GuitarProParser
  # This class represents settings of tracks.
  #
  # == Attributes
  # All attributes are read-only
  #
  # * +drums+                                 (boolean)   Drums track
  # * +twelve_stringed_guitar+                (boolean)   12 stringed guitar track
  # * +banjo+                                 (boolean)   Banjo track
  # * +solo_playback+                         (boolean)   Marked for solo playback (> 5.0 only)
  # * +mute_playback+                         (boolean)   Marked for mute playback (> 5.0 only)
  # * +rse_playback+                          (boolean)   Use RSE playback (track instrument option) (> 5.0 only)
  # * +indicate_tuning+                       (boolean)   Indicate tuning on the score (track properties) (> 5.0 only)
  # * +name+                                  (string)    Track name
  # * +strings_count+                         (integer)   Number of strings used in this track
  # * +strings_tuning+                        (array)     Array of MIDI notes each string plays open. E.g. [E5, B4, G4, D4, A3, E3] for standart tuning
  # * +midi_port+                             (integer)   MIDI port used
  # * +midi_channel+                          (integer)   MIDI channel used (must be 10 if this is a drum track)
  # * +midi_channel_for_effects+              (integer)   MIDI channel used for effects
  # * +frets_count+                           (integer)   Number of frets used for this instrument
  # * +capo+                                  (integer)   The fret number at which a capo is placed (0 for no capo)
  # * +color+                                 (array)     Track color (RGB intensities). E.g. [255, 0, 0] for red.
  # * +diagrams_below_the_standard_notation+  (boolean)   Diagrams/chords below the standard notation (> 5.0 only)
  # * +show_rythm_with_tab+                   (boolean)   Show rhythm with tab (> 5.0 only)
  # * +force_horizontal_beams+                (boolean)   Force horizontal beams (> 5.0 only)
  # * +force_channels_11_to_16+               (boolean)   Force channels 11 to 16 (> 5.0 only)
  # * +diagrams_list_on_top_of_score+         (boolean)   Diagrams list on top of the score (> 5.0 only)
  # * +diagrams_in_the_score+                 (boolean)   Diagrams in the score (> 5.0 only)
  # * +auto_let_ring+                         (boolean)   Auto-Let Ring (> 5.0 only)
  # * +auto_brush+                            (boolean)   Auto Brush (> 5.0 only)
  # * +extend_rhytmic_inside_the_tab+         (boolean)   Extend rhythmic inside the tab (> 5.0 only)
  # * +midi_bank+                             (integer)   MIDI bank (> 5.0 only)
  # * +human_playing+                         (integer)   Human playing in percents (track instrument options) (> 5.0 only)
  # * +auto_accentuation+                     (integer)   Auto-Accentuation on the Beat (track instrument options) (> 5.0 only) # TODO Not sure that it works
  # * +sound_bank+                            (integer)   Selected sound bank (track instrument options) (> 5.0 only)
  # * +equalizer+                             (array)     Equalizer setup. Represented as array with this values:
  #                                                         number of increments of .1dB the volume for the low frequency band is lowered
  #                                                         number of increments of .1dB the volume for the mid frequency band is lowered
  #                                                         number of increments of .1dB the volume for the high frequency band is lowered
  #                                                         number of increments of .1dB the volume for all frequencies is lowered (gain)
  #                                                       (> 5.0 only)
  # * +instrument_effect_1+                   (string)    Track instrument effect 1 (> 5.0 only)
  # * +instrument_effect_2+                   (string)    Track instrument effect 2 (> 5.0 only)
  # * +bars+                                  (array)     Bars of this track
  #        
  class Track

    include GuitarProHelper

    # Track bitmask
    attr_reader :drums,
                :twelve_stringed_guitar,
                :banjo,
                :solo_playback,
                :mute_playback,
                :rse_playback,
                :indicate_tuning

    # Track options
    attr_reader :name, :strings_count, :strings_tuning, 
                :midi_port, :midi_channel, :midi_channel_for_effects,
                :frets_count, :capo, :color

    # Guitar Pro 5 track properties bitmask 1
    attr_reader :diagrams_below_the_standard_notation,
                :show_rythm_with_tab,
                :force_horizontal_beams,
                :force_channels_11_to_16,
                :diagrams_list_on_top_of_score,
                :diagrams_in_the_score

    # Guitar Pro 5 track properties bitmask 1
    attr_reader :auto_let_ring,
                :auto_brush,
                :extend_rhytmic_inside_the_tab

    # Guitar Pro 5 track properties
    attr_reader :midi_bank, :human_playing, :auto_accentuation,
                :sound_bank, :equalizer,
                :instrument_effect_1, :instrument_effect_2

    attr_accessor :bars
    

    def initialize parser, song, number
      @parser = parser
      @version = song.version

      @bars = []

      # Bit 0 (LSB):  Drums track
      # Bit 1:        12 stringed guitar track
      # Bit 2:        Banjo track
      # Bit 3:        Blank bit
      # Bit 4:        Marked for solo playback
      # Bit 5:        Marked for muted playback
      # Bit 6:        Use RSE playback (track instrument option)
      # Bit 7:        Indicate tuning on the score (track properties)
      bits = Parser.to_bitmask(@parser.read_byte)
      @drums = !bits[0].zero?
      @twelve_stringed_guitar = !bits[1].zero?
      @banjo = !bits[2].zero?
      @solo_playback = !bits[4].zero?
      @mute_playback = !bits[5].zero?
      @rse_playback = !bits[6].zero?
      @indicate_tuning = !bits[7].zero?
     
      parse_name
      @strings_count = @parser.read_integer
      parse_strings_tuning
      @midi_port = @parser.read_integer
      @midi_channel = @parser.read_integer
      @midi_channel_for_effects = @parser.read_integer
      @frets_count = @parser.read_integer
      @capo = @parser.read_integer
      parse_color

      if @version > 5.0
        parse_track_properties_1
        parse_track_properties_2
        @parser.skip_byte
        @midi_bank = @parser.read_byte
        @human_playing = @parser.read_byte
        @auto_accentuation = @parser.read_byte
        @parser.increment_offset 31
        @sound_bank = @parser.read_byte
        @parser.increment_offset 7

        @equalizer = []
        4.times do
          @equalizer << @parser.read_byte
        end

        @instrument_effect_1 = @parser.read_chunk
        @instrument_effect_2 = @parser.read_chunk
      end

      @parser.increment_offset 45 if @version == 5.0
    end

    private

    def parse_name
      track_name_field_length = 41

      length = @parser.read_byte
      @name = @parser.read_string length

      @parser.increment_offset (track_name_field_length - length - 1)
    end

    def parse_strings_tuning
      @strings_tuning = []
      @strings_count.times do
        @strings_tuning << (digit_to_note(@parser.read_integer))
      end

      # Skip padding if there are less than 7 strings
      (7 - @strings_count).times { @parser.skip_integer }
    end

    def parse_color
      @color = []
      3.times do
        @color << @parser.read_byte
      end
      @parser.skip_byte
    end

    def parse_track_properties_1
        # The track properties 1 bitmask declares various options in track properties:
        # Bit 0 (LSB):  Unknown (something to do with tablature notation being enabled)
        # Bit 1:        Unknown
        # Bit 2:        Diagrams/chords below the standard notation
        # Bit 3:        Show rhythm with tab
        # Bit 4:        Force horizontal beams
        # Bit 5:        Force channels 11 to 16
        # Bit 6:        Diagrams list on top of the score
        # Bit 7 (MSB):  Diagrams in the score
        bits = Parser.to_bitmask(@parser.read_byte)
        @diagrams_below_the_standard_notation = !bits[2].zero?
        @show_rythm_with_tab = !bits[3].zero?
        @force_horizontal_beams = !bits[4].zero?
        @force_channels_11_to_16 = !bits[5].zero?
        @diagrams_list_on_top_of_score = !bits[6].zero?
        @diagrams_in_the_score = !bits[7].zero?
    end

    def parse_track_properties_2
        # The track properties 2 bitmask declares various options in track properties/instrument:
        # Bit 0 (LSB):  Unknown
        # Bit 1:        Auto-Let Ring
        # Bit 2:        Auto Brush
        # Bit 3:        Extend rhythmic inside the tab
        # Bits 4-7:     Unknown
        bits = Parser.to_bitmask(@parser.read_byte)
        @auto_let_ring = !bits[1].zero?
        @auto_brush = !bits[2].zero?
        @extend_rhytmic_inside_the_tab = !bits[3].zero?
    end
  end

end