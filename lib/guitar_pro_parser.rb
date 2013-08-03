require 'guitar_pro_parser/version'
require 'guitar_pro_parser/song'
require 'guitar_pro_parser/page_setup'
require 'guitar_pro_parser/channel'
require "guitar_pro_parser/track"
require "guitar_pro_parser/bar_settings"
require "guitar_pro_parser/bar"
require 'guitar_pro_parser/beat'
require 'guitar_pro_parser/chord_diagram'
require 'guitar_pro_parser/note'

require 'guitar_pro_parser/io/gp5_writer'
require 'guitar_pro_parser/io/output_stream'

require 'guitar_pro_parser/io/input_stream'

module GuitarProParser

  # Reads the whole Guitar Pro file and returns song object
  def self.read_file(filename)
    Song.new(filename)
  end

  # Read only header information (such as title, artist, etc.) 
  # from Guitar Pro file
  def self.read_headers(filename)
    Song.new(filename, true)
  end

  # Saves song to .gp5 file
  def self.save_file_as_gp5(song, filename)
    
  end

end