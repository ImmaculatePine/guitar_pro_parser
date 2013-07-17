module GuitarProParser

  require "guitar_pro_parser/parser"
  require "guitar_pro_parser/guitar_pro_helper"

  class Beat

    extend GuitarProHelper

    REST_TYPES = { 0 => :empty_beat, 
                   2 => :rest }

    DURATIONS = { -2 => :whole,
                  -1 => :half,
                   0 => :quarter,
                   1 => :eighth,
                   2 => :sixteens,
                   3 => :thirty_second,
                   4 => :sixty_fourth }

    attr_boolean :dotted, :has_chord_diagram, :has_text, :has_beat_effects,
                 :has_mix_table_change, :tuplet, :rest

    attr_reader :rest_type, :duration, :tuplet_type

    def initialize(parser, version)
      @parser = parser
      @version = version

      parse_bitmask
      @rest_type = REST_TYPES.fetch(@parser.read_byte) if rest?
      @duration = DURATIONS.fetch(@parser.read_byte)
      @tuplet_type = @parser.read_integer if tuplet?
      
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
      bits = @parser.to_bitmask(@parser.read_byte, :booleans)
      @dotted = bits[0]
      @has_chord_diagram = bits[1]
      @has_text = bits[2]
      @has_beat_effects = bits[3]
      @has_mix_table_change = bits[4]
      @tuplet = bits[5]
      @rest = bits[6]
    end

    
  end

end