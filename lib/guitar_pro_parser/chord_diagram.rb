require 'guitar_pro_parser/guitar_pro_helper'

module GuitarProParser

  class ChordDiagram
    
    attr_reader :beat    
    attr_reader :name, :start_fret, :frets

   def initialize parser, version, beat
      @parser = parser
      @version = version
      @beat = beat

      format = @parser.read_byte
      if format == 0
        parse_gp3_format
      else
        parse_gp4_format
      end
    end

    def parse_gp3_format
      @name = @parser.read_chunk
      @start_fret = @parser.read_integer

      unless @start_fret.zero?
        @frets = []
        @beat.track.strings_count.times do
          frets << @parser.read_integer
        end
      end
    end

    def parse_gp4_format
      @parser.increment_offset(105) # TODO
    end

  end
end