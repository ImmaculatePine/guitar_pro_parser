module GuitarProParser

  require "guitar_pro_parser/parser"
  require "guitar_pro_parser/guitar_pro_helper"

  class Note

    extend GuitarProHelper

    NOTE_TYPES = [:normal, :tie, :dead]
    NOTE_DYNAMICS = %w(ppp pp p mp mf f ff fff)
    DEFAULT_DYNAMIC = 5
    GRACE_NOTE_TRANSITION_TYPES = [:none, :slide, :bend, :hammer]
    GRACE_NOTE_DURATIONS = { '3' => 16, '2' => 32, '1' => 64 }
    TREMOLO_PICKING_SPEEDS = { '3' => 32, '2' => 16, '1' => 8 }
    
    SLIDE_TYPES = [:no_slide, :shift_slide, :legato_slide, :slide_out_and_downwards, :slide_out_and_upwards, :slide_in_from_below, :slide_in_from_above]
    MAP_SLIDE_TYPES_GP5 = { '0'=>0, '1'=>1, '2'=>2, '4'=>3, '8'=>4, '16'=>5, '32'=>6 }
    MAP_SLIDE_TYPES_GP4 = { '-2'=>0, '-1'=>1, '0'=>2, '1'=>3, '2'=>4, '3'=>5, '4'=>6 }
    
    HARMONIC_TYPES = [:none, :natural, :artificial, :tapped, :pinch, :semi]
    
    TRILL_PERIODS = [4, 8, 16]

    attr_boolean :time_independent_duration, :accentuated, :ghost,
                 :has_effects, :has_dynamic, :has_type, :has_fingering

    attr_boolean :has_bend, :has_hammer_or_pull, :has_slide, :let_ring, :has_grace_note
 
    attr_boolean :staccato, :palm_mute, :tremolo, :has_harmonic, :has_trill, :vibrato
 
    attr_reader :type, :dynamic, :fret,
                :left_hand_fingering, :right_hand_fingering,
                :bend, :grace_note, :tremolo_speed, :slide,
                :harmonic, :trill

    def initialize(parser, version)
      @parser = parser
      @version = version

      parse_bitmask
      
      @type = NOTE_TYPES.fetch(@parser.read_byte - 1) if has_type?

      # Ignore time-independed duration data for Guitar Pro 4 and less
      @parser.skip_short_integer if @version < 5.0 and time_independent_duration?

      @dynamic = NOTE_DYNAMICS.fetch(DEFAULT_DYNAMIC)
      @dynamic = NOTE_DYNAMICS.fetch(@parser.read_byte - 1) if has_dynamic?

      @fret = @parser.read_byte

      if has_fingering?
        left_finger = @parser.read_byte
        right_finger = @parser.read_byte
        @left_hand_fingering = FINGERS.fetch(left_finger) unless left_finger == -1
        @right_hand_fingering = FINGERS.fetch(right_finger) unless right_finger == -1
      end

      # Ignore time-independed duration data for Guitar Pro 5
      @parser.increment_offset 8 if @version >= 5.0 and time_independent_duration?

      # Skip padding
      @parser.skip_byte if @version >= 5.0

      # Set default effect values
      @vibrato = false
      @has_grace_note = false
      @let_ring = false
      @has_hammer_or_pull = false
      @has_trill = false
      @has_bend = false
      @staccato = false
      @palm_mute = false
      @has_harmonic = false
      @tremolo= false
      @has_slide = false

      parse_effects if has_effects?
    end

    private

    def parse_bitmask
      # The note bitmask declares which parameters are defined for the note:
      # Bit 0 (LSB):  Time-independent duration
      # Bit 1:    Heavy Accentuated note
      # Bit 2:    Ghost note
      # Bit 3:    Note effects present
      # Bit 4:    Note dynamic
      # Bit 5:    Note type
      # Bit 6:    Accentuated note
      # Bit 7:    Right/Left hand fingering

      bits = Parser.to_bitmask(@parser.read_byte, :booleans)
      # TODO: Find in Guitar Pro how to enable this feature
      @time_independent_duration = bits[0]

      # Guitar Pro 5 files has 'Heavy accentuated' (bit 1) and 'Accentuated' (bit 6) states.
      # Guitar Pro 4 and less have only 'Accentuated' (bit 6) state.
      # So the only supported option for note is just 'Accentuated'.
      @accentuated = bits[1] || bits[6]

      @ghost = bits[2]
      @has_effects = bits[3]
      @has_dynamic = bits[4]
      @has_type = bits[5]
      @has_fingering = bits[7]
    end

    def parse_effects
      parse_effects_bitmask_1
      parse_effects_bitmask_2 if @version >= 4.0

      @bend = parse_bend(@parser) if has_bend?
      parse_grace_note if has_grace_note?
      @tremolo_speed = TREMOLO_PICKING_SPEEDS.fetch(@parser.read_byte.to_s) if tremolo?
      parse_slide if has_slide?
      parse_harmonic if has_harmonic?
      parse_trill if has_trill?
    end

    def parse_effects_bitmask_1
      # The note effect 1 bitmask declares which effects are defined for the note:
      # Bit 0 (LSB):  Bend present
      # Bit 1:    Hammer on/Pull off from the current note
      # Bit 2:    Slide from the current note (GP3 format version)
      # Bit 3:    Let ring
      # Bit 4:    Grace note
      # Bits 5-7: Unused (set to 0)
      bits = Parser.to_bitmask(@parser.read_byte, :booleans)
      @has_bend = bits[0]
      @has_hammer_or_pull = bits[1]
      @has_slide = bits[2]
      @let_ring = bits[3]
      @has_grace_note = bits[4]
    end

    def parse_effects_bitmask_2
      # The note effect 2 bitmask declares more effects for the note:
      # Bit 0 (LSB):  Note played staccato
      # Bit 1:    Palm Mute
      # Bit 2:    Tremolo Picking
      # Bit 3:    Slide from the current note
      # Bit 4:    Harmonic note
      # Bit 5:    Trill
      # Bit 6:    Vibrato
      # Bit 7 (MSB):  Unused (set to 0)
      bits = Parser.to_bitmask(@parser.read_byte, :booleans)
      @staccato = bits[0]
      @palm_mute = bits[1]
      @tremolo = bits[2]
      @has_slide = bits[3]
      @has_harmonic = bits[4]
      @has_trill = bits[5]
      @vibrato = bits[6]
    end

    def parse_grace_note
      fret = @parser.read_byte
      dynamic = NOTE_DYNAMICS.fetch(@parser.read_byte - 1)
      transition = GRACE_NOTE_TRANSITION_TYPES.fetch(@parser.read_byte)
      duration = GRACE_NOTE_DURATIONS.fetch(@parser.read_byte.to_s)
      dead = false
      position = :before_the_beat

      if @version >= 5.0
        bits = Parser.to_bitmask(@parser.read_byte, :booleans)
        dead = bits[0]
        position = :on_the_beat if bits[1]
      end

      @grace_note = { fret: fret, dynamic: dynamic, transition: transition, duration: duration, dead: dead, position: position }
    end

    def parse_slide
      value = @parser.read_byte.to_s

      if @version >= 5.0
        @slide = SLIDE_TYPES.fetch(MAP_SLIDE_TYPES_GP5.fetch(value))
      else
        @slide = SLIDE_TYPES.fetch(MAP_SLIDE_TYPES_GP5.fetch(value))
      end
    end

    def parse_harmonic
      @harmonic = {}

      type = nil
      harmonic_type_index = @parser.read_byte
      if @version >= 5.0
        type = HARMONIC_TYPES.fetch(harmonic_type_index)
      else
        map_of_gp4_harmonics = { '0' => 0,
                                 '1' => 1,
                                 '15' => 2,
                                 '17' => 2,
                                 '22' => 2,
                                 '3' => 3,
                                 '4' => 4,
                                 '5' => 5 }
        type = HARMONIC_TYPES.fetch(map_of_gp4_harmonics[harmonic_type_index.to_s])
      end
      @harmonic[:type] = type

      # Guitar Pro 5 has additional data about artificial and tapped harmonics
      # But Guitar Pro 4 and less have not this data so we'll skip it now
      if @version >= 5.0
        case type
        when :artificial
          # Note (1 byte), note type (1 byte) and harmonic octave (1 byte)
          # E.g. C# 15ma
          @parser.increment_offset(3)
        when :tapped
          # Tapped fret (1 byte)
          @parser.skip_byte
        end
      end
    end

    def parse_trill
      fret = @parser.read_byte
      period = TRILL_PERIODS.fetch(@parser.read_byte)
      @trill = { fret: fret, period: period }
    end

    

  end
end