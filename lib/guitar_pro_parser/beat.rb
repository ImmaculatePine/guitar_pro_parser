require 'guitar_pro_parser/guitar_pro_helper'
require 'guitar_pro_parser/chord_diagram'
require 'guitar_pro_parser/note'

module GuitarProParser

  class Beat

    include GuitarProHelper
    extend GuitarProHelper

    REST_TYPES = { '0' => :empty_beat, 
                   '2' => :rest }

    DURATIONS = { '254' => :whole, # TODO: I don't know why
                  '255' => :half,  # these 2 keys are not -2 and -1
                   '0' => :quarter,
                   '1' => :eighth,
                   '2' => :sixteens,
                   '3' => :thirty_second,
                   '4' => :sixty_fourth }

    STRING_EFFECTS = [:tremolo_bar, :tapping, :slapping, :popping]
    
    STROKE_EFFECT_SPEEDS = [:none, 128, 64, 32, 16, 8, 4]

    STROKE_DIRECTIONS = [:none, :up, :down]
 
    attr_reader :track

    attr_boolean :dotted, :has_chord_diagram, :has_text, :has_effects,
                 :has_mix_table_change, :tuplet, :rest

    attr_reader :duration, :rest_type, :tuplet_type, :chord_diagram, :text, :effects, :mix_table, :strings, :transpose

    def initialize(parser, version, track)
      @parser = parser
      @version = version
      @track = track

      parse_bitmask
      # @rest_type = REST_TYPES.fetch(@parser.read_byte) if rest?
      @rest_type = @parser.read_byte if rest? # TODO
      @duration = DURATIONS.fetch(@parser.read_byte.to_s)
      @tuplet_type = @parser.read_integer if tuplet?
      @chord_diagram = ChordDiagram.new(@parser, @version, self) if has_chord_diagram?
      @text = @parser.read_chunk if has_text?
      @effects = {}
      parse_effects if has_effects?
      parse_mix_table_change if has_mix_table_change?
      parse_strings
      parse_transpose if @version >= 5.0
    end

    def has_effect?(effect)
      @effects.include? effect
    end

    private

    def parse_bitmask
      # The beat bitmask declares which parameters are defined for the beat:
      # Bit 0 (LSB):  Dotted note
      # Bit 1:        Chord diagram present
      # Bit 2:        Text present
      # Bit 3:        Beat effects present
      # Bit 4:        Mix table change present
      # Bit 5:        This beat is an N-tuplet
      # Bit 6:        Is a rest beat
      # Bit 7 (MSB):  Unused (set to 0)
      bits = @parser.read_bitmask
      @dotted = bits[0]
      @has_chord_diagram = bits[1]
      @has_text = bits[2]
      @has_effects = bits[3]
      @has_mix_table_change = bits[4]
      @tuplet = bits[5]
      @rest = bits[6]
    end

    def parse_effects
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
      # Byte 2 (extended beat effects, only if the major file version is >= 4):
      #  Bit 0:     Rasguedo
      #  Bit 1:     Pickstroke
      #  Bit 2:     Tremolo bar
      #  Bits 3-7:  Unused (set to 0)
      bits = @parser.read_bitmask
      add_effect(:vibrato) if bits[0]
      add_effect(:wide_vibrato) if bits[1]
      add_effect(:natural_harmonic) if bits[2]
      add_effect(:artificial_harmonic) if bits[3]
      add_effect(:fade_in) if bits[4]
      add_effect(:string_effect) if bits[5]
      add_effect(:stroke_effect) if bits[6]

      if @version >= 4.0
        bits = @parser.read_bitmask
        add_effect(:rasguedo) if bits[0]
        add_effect(:pickstroke) if bits[1]
        add_effect(:tremolo_bar) if bits[2]
      end

      if has_effect? :string_effect
        # @effects[:string_effect] = STRING_EFFECTS.fetch(@parser.read_byte)
        @effects[:string_effect] = @parser.read_byte # TODO
        
        # Skip a value applied to the string effect in old Guitar Pro versions
        @parser.read_integer if @version < 4.0
      end

      if has_effect? :tremolo_bar
        @effects[:tremolo_bar] = parse_bend(@parser)
      end
      
      if has_effect? :stroke_effect
        # upstroke = STROKE_EFFECT_SPEEDS.fetch(@parser.read_byte)
        # downstroke = STROKE_EFFECT_SPEEDS.fetch(@parser.read_byte)
        upstroke = @parser.read_byte # TODO
        downstroke = @parser.read_byte # TODO
        @effects[:stroke_effect] = { upstroke_speed: upstroke, downstroke_speed: downstroke }
      end

      if has_effect? :pickstroke
        @effects[:pickstroke] = STROKE_DIRECTIONS.fetch(@parser.read_byte)
      end

    end
  
    def add_effect(effect)
      @effects[effect] = nil
    end

    def parse_mix_table_change
      @mix_table = {}

      instrument = @parser.read_byte
      @mix_table[:instrument] == instrument unless instrument == -1

      if @version >= 5.0
        # RSE related 4 digit numbers (-1 if RSE is disabled)
        3.times { @parser.skip_integer }
        @parser.skip_integer # Padding
      end

      volume = @parser.read_byte
      pan = @parser.read_byte
      chorus = @parser.read_byte
      reverb = @parser.read_byte
      phaser = @parser.read_byte
      tremolo = @parser.read_byte
      
      tempo_string = ''
      tempo_string = @parser.read_chunk if @version >= 5.0
      tempo = @parser.read_integer

      
      @mix_table[:volume] = { value: volume, transition: @parser.read_byte } unless volume == -1
      @mix_table[:pan] = { value: pan, transition: @parser.read_byte } unless pan == -1
      @mix_table[:chorus] = { value: chorus, transition: @parser.read_byte } unless chorus == -1
      @mix_table[:reverb] = { value: reverb, transition: @parser.read_byte } unless reverb == -1
      @mix_table[:phaser] = { value: phaser, transition: @parser.read_byte } unless phaser == -1
      @mix_table[:tremolo] = { value: tremolo, transition: @parser.read_byte } unless tremolo == -1

      unless tempo == -1
        @mix_table[:tempo] = { value: tempo, transition: @parser.read_byte, text: tempo_string }
        @mix_table[:tempo][:hidden_text] = @parser.read_byte if @version > 5.0
      end
      
      # The mix table change applied tracks bitmask declares which mix change events apply to all tracks (set = all tracks, reset = current track only):
      # Bit 0 (LSB):  Volume change
      # Bit 1:    Pan change
      # Bit 2:    Chorus change
      # Bit 3:    Reverb change
      # Bit 4:    Phaser change
      # Bit 5:    Tremolo change
      # Bits 6-7: Unused
      # TODO: parse this bitmask
      @parser.skip_byte if @version >= 4.0

      # Padding
      @parser.skip_byte if @version >= 5.0
      
      if @version > 5.0
        @mix_table[:rse_effect_2] = @parser.read_chunk
        @mix_table[:rse_effect_1] = @parser.read_chunk
      end
    end

    def parse_strings
      strings_bitmask = @parser.read_bitmask
      used_strings = []
      (0..6).to_a.reverse.each { |i| used_strings << strings_bitmask[i] }

      @strings = {}

      7.times do |i|
          @strings["#{i+1}"] = Note.new(@parser, @version) if used_strings[i]
      end
    end

    # TODO: write transpose parsing
    def parse_transpose
      # Bits 0-3: Unknown/unused
      # Bit 4:    8va (up one octave)
      # Bit 5:    8vb (down one octave)
      # Bit 6:    15ma (up two octaves)
      # Bit 7:    Unknown/unused
      bits1 = @parser.read_bitmask

      # Bit 8:    15mb (down two octaves)
      # Bits 9-10:  Unknown/unused
      # Bit 11:   An extra unknown data byte follows this bitmask
      # Bits 12-15: Unknown/unused
      bits2 = @parser.read_bitmask

      @transpose = '8va' if bits1[4]
      @transpose = '8vb' if bits1[5]
      @transpose = '15ma' if bits1[6]
      @transpose = '15mb' if bits2[0]

      # Unknown data
      @parser.skip_byte if bits2[3]
    end

  end

end