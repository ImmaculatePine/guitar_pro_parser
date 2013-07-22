module GuitarProParser

  # This class represents tracks.
  # Beside track's settings (see attributes) it contain bars (@bars attribute) that contain beats and notes.
  #
  # == Attributes
  #
  # * +drums+                                 (boolean)   Drums track
  # * +twelve_stringed_guitar+                (boolean)   12 stringed guitar track
  # * +banjo+                                 (boolean)   Banjo track
  # * +solo_playback+                         (boolean)   Marked for solo playback (> 5.0 only)
  # * +mute_playback+                         (boolean)   Marked for mute playback (> 5.0 only)
  # * +rse_playback+                          (boolean)   Use RSE playback (track instrument option) (> 5.0 only)
  # * +indicate_tuning+                       (boolean)   Indicate tuning on the score (track properties) (> 5.0 only)
  # * +name+                                  (string)    Track name
  # * +strings+                               (array)     Array of MIDI notes each string plays open. E.g. [E5, B4, G4, D4, A3, E3] for standart tuning
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

    attr_accessor :drums,
                  :twelve_stringed_guitar,
                  :banjo,
                  :solo_playback,
                  :mute_playback,
                  :rse_playback,
                  :indicate_tuning,
                  :name,
                  :strings,
                  :midi_port,
                  :midi_channel,
                  :midi_channel_for_effects,
                  :frets_count,
                  :capo,
                  :color,
                  :diagrams_below_the_standard_notation,
                  :show_rythm_with_tab,
                  :force_horizontal_beams,
                  :force_channels_11_to_16,
                  :diagrams_list_on_top_of_score,
                  :diagrams_in_the_score,
                  :auto_let_ring,
                  :auto_brush,
                  :extend_rhytmic_inside_the_tab,
                  :midi_bank,
                  :human_playing,
                  :auto_accentuation,
                  :sound_bank,
                  :equalizer,
                  :instrument_effect_1,
                  :instrument_effect_2,
                  :bars

     def initialize
      # Initialize attributes by default values
      @drums = false
      @twelve_stringed_guitar = false
      @banjo = false
      @solo_playback = false
      @mute_playback = false
      @rse_playback = false
      @indicate_tuning = false
      @name = 'Track'
      @strings = %w(E5 B4 G4 D4 A3 E3)
      @midi_port = 1
      @midi_channel = 16
      @midi_channel_for_effects = 16
      @frets_count = 24
      @capo = 0
      @color = [255, 0, 0]

      @diagrams_below_the_standard_notation = false
      @show_rythm_with_tab = false
      @force_horizontal_beams = false
      @force_channels_11_to_16 = false
      @diagrams_list_on_top_of_score = false
      @diagrams_in_the_score = false

      @auto_let_ring = false
      @auto_brush = false
      @extend_rhytmic_inside_the_tab = false

      @midi_bank = 0
      @human_playing = 0
      @auto_accentuation = 0
      @sound_bank = 0

      @equalizer = Array.new(4, 0)

      @instrument_effect_1 = ''
      @instrument_effect_2 = ''

      @bars = []
    end
    
  end

end