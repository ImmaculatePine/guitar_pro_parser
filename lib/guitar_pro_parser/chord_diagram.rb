module GuitarProParser

  class ChordDiagram
    
    attr_accessor :name, :start_fret, :frets

    def initialize
      @name = ''
      @start_fret = 0
      @frets = []
    end

  end
end