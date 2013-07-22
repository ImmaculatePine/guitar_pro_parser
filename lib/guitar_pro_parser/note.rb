module GuitarProParser

  class Note

    attr_accessor :type,
                  :time_independent_duration,
                  :accentuated,
                  :ghost,
                  :dynamic,
                  :fret,
                  :fingers,
                  :vibrato,
                  :grace,
                  :let_ring,
                  :hammer_or_pull,
                  :trill,
                  :bend,
                  :staccato,
                  :palm_mute,
                  :harmonic,
                  :tremolo,
                  :slide

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