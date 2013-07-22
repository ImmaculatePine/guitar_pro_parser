require 'guitar_pro_parser/version'
require 'guitar_pro_parser/song'
require 'guitar_pro_parser/beat'
require 'guitar_pro_parser/chord_diagram'
require 'guitar_pro_parser/note'

module GuitarProParser

  def self.read_file(filename)
    Song.new(filename)
  end

end