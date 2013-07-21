require 'guitar_pro_parser/version'
require 'guitar_pro_parser/song'
require 'guitar_pro_parser/beat'

module GuitarProParser

  def self.read_file(filename)
    Song.new(filename)
  end

end