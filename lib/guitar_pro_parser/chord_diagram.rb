module GuitarProParser

  class ChordDiagram
    
    attr_accessor :name,
                  :base_fret,
                  :frets,
                  :display_as,
                  :root,
                  :type

    # Determines if the chord goes until the ninth, the eleventh, or the thirteenth.
    attr_accessor :nine_eleven_thirteen
    
    attr_accessor :bass,
                  :tonality,
                  :add,
                  :fifth_tonality,
                  :ninth_tonality,
                  :eleventh_tonality,
                  :barres,
                  :intervals,
                  :fingers,
                  :display_fingering

    def initialize
      @name = ''
      @base_fret = 0
      @frets = []
      @display_as = :sharp
      @root = nil
      @type = 'M'
      @nine_eleven_thirteen = 0
      @bass = nil
      @tonality = :perfect
      @add = false
      @fifth_tonality = :perfect
      @ninth_tonality = :perfect
      @eleventh_tonality = :perfect
      @barres = []
      @intervals = []
      @fingers = []
      @display_fingering = false
    end

    def add_barre(fret, start_string, end_string)
      @barres << { fret: fret, start_string: start_string, end_string: end_string }
    end

  end
end