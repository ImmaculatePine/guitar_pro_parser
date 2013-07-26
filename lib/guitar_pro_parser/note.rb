module GuitarProParser

  class Note

    # Type of note: normal, tie or dead (see GuitarProHelper::NOTE_TYPES)
    attr_accessor :type
    
    # Time independent duration data from version 4 of the format.
    # TODO: It is parsed but I don't know if it's used correctly
    attr_accessor :time_independent_duration 

    # (Boolean) Is this note accentuated?
    attr_accessor :accentuated

    # (Boolean) Is this note a ghost note?
    attr_accessor :ghost

    # Note dynamic. Default is 'f' (see GuitarProHelper::NOTE_DYNAMICS)
    attr_accessor :dynamic

    # Fret
    attr_accessor :fret

    # (Hash) Left and right fingering. E.g.:
    #   { left: :middle, right: :thumb }
    # See fingers in GuitarProHelper::FINGERS
    attr_accessor :fingers

    # (Boolean) Has this note vibrato effect?
    attr_accessor :vibrato

    # (Hash) Grace note. E.g.:
    #   { fret: 2, 
    #     dynamic: 'ff',
    #     transition: :hammer, # see GuitarProHelper::GRACE_NOTE_TRANSITION_TYPES
    #     duration: 32, # see GuitarProHelper::GRACE_NOTE_DURATIONS
    #     dead: false,
    #     position: :before_the_beat # or :on_the_beat }
    # nil by default
    attr_accessor :grace

    # (Boolean) Has this note let ring effect?
    attr_accessor :let_ring

    # (Boolean) Has this note hammer on or pull off effect?
    attr_accessor :hammer_or_pull

    # (Hash) Trill effect. E.g.:
    #   { fret: 7, 
    #     period: 16 # see GuitarProHelper::TRILL_PERIODS }
    # nil by default
    attr_accessor :trill

    # (Hash) Bend effect. E.g.:
    #   { type: :bend, # See GuitarProHelper::BEND_TYPES
    #     height: 100, # Bend height. It is 100 per tone and goes by quarter tone.
    #     points: # List of points used to display the bend
    #     [ 
    #       { time: 0, 
    #         pitch_alteration: 0, # The same rules as for height
    #         vibrato_type: :none }, # See GuitarProHelper::BEND_VIBRATO_TYPES
    #       { time: 60, pitch_alteration: 100, vibrato_type: :none }
    #     ]
    #   }
    # nil by default
    attr_accessor :bend

    # (Boolean) Has this note stacatto effect?
    attr_accessor :staccato

    # (Boolean) Has this note palm mute effect?
    attr_accessor :palm_mute

    # (Hash) Harmonic of the note. E.g.:
    #   { type: :artificial}
    # Full list of harmonic types see in GuitarProHelper::HARMONIC_TYPES
    # nil by default
    attr_accessor :harmonic

    # (Hash) Tremolo effect. E.g.:
    #   { speed: 16 } # See GuitarProHelper::TREMOLO_PICKING_SPEEDS
    # nil by default
    attr_accessor :tremolo

    # Slide effect. List of slides see in GuitarProHelper::SLIDE_TYPES
    # nil by default
    attr_accessor :slide

    def initialize
      @type = :normal
      @time_independent_duration = false
      @accentuated = false
      @ghost = false
      @dynamic = 'f'
      @fret = 0
      @fingers = { left: nil, right: nil }
      @vibrato = false
      @grace = nil
      @let_ring = false
      @hammer_or_pull = false
      @trill = nil
      @bend = nil
      @staccato = false
      @palm_mute = false
      @harmonic = nil
      @tremolo = nil
      @slide = nil
    end

    def add_left_hand_finger(finger)
      @fingers[:left] = finger
    end

    def add_right_hand_finger(finger)
      @fingers[:right] = finger
    end

    def add_grace(fret, dynamic, transition, duration, dead, position)
      @grace = { fret: fret, dynamic: dynamic, transition: transition, duration: duration, dead: dead, position: position }      
    end

    def add_tremolo(speed)
      @tremolo = { speed: speed }
    end

    def add_harmonic(type)
      @harmonic = { type: type }
    end

    def add_trill(fret, period)
      @trill = { fret: fret, period: period }
    end

  end
end