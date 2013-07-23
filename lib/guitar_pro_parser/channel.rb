module GuitarProParser

  class Channel

    attr_accessor :instrument,
                  :volume,
                  :pan,
                  :chorus,
                  :reverb,
                  :phaser,
                  :tremolo

    def initialize
      @instrument = 0
      @volume = 13
      @pan = 8
      @chorus = 0
      @reverb = 0
      @phaser = 0
      @tremolo = 0
    end

  end

end