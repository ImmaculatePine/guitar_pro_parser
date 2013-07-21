require "guitar_pro_parser/version"
require "guitar_pro_parser/song"

module GuitarProParser

  def self.read_file(filename)
    Song.new(filename)
  end

end