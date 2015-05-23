require 'guitar_pro_parser/io/reader'

module GuitarProParser
  
  # This class represents the content of Guitar Pro file.
  # It can be initialized by path to .gp[3,4,5] file. Then it will automatically parse its data.
  # Or it can be just instantiated with default values of the attributes.
  #
  class Song

    include GuitarProHelper

    # Guitar Pro version
    attr_accessor :version

    # Song information
    attr_accessor :title, :subtitle, :artist, :album, :lyricist,
                  :composer, :copyright, :transcriber, :instructions

    # Array of notices
    attr_accessor :notices

    # (Boolean) Shuffle rhythm feel. < 5.0 only. 
    # In version 5 of the format it is true when
    # there is at least 1 bar with triplet feel.
    attr_accessor :triplet_feel

    # Associated track for the lyrics (>= 4.0 only)    
    attr_accessor :lyrics_track

    # Lyrics represented as array of hashes with 5 elements
    # (for lyrics lines from 1 to 5). 
    # Each line has lyrics' text and number of bar where it starts
    #   {text: "Some text", bar: 1}
    # (>= 4.0 only)
    attr_accessor :lyrics

    # Master volume (value from 0 - 200, default is 100) (>= 5.0 only)
    attr_accessor :master_volume

    # Array of equalizer settings. 
    # Each one is represented as number of increments of .1dB the volume for 
    # * 32Hz band is lowered
    # * 60Hz band is lowered
    # * 125Hz band is lowered
    # * 250Hz band is lowered
    # * 500Hz band is lowered
    # * 1KHz band is lowered
    # * 2KHz band is lowered
    # * 4KHz band is lowered
    # * 8KHz band is lowered
    # * 16KHz band is lowered
    # * overall volume is lowered (gain)
    attr_accessor :equalizer

    # (PageSetup) Data about page setup such as paddings, width, height, etc. (>= 5.0 only)
    attr_accessor :page_setup

    # (String) Tempo text
    attr_accessor :tempo

    # Tempo as beats per minute
    attr_accessor :bpm

    # Key (signature) at the beginning of the piece. 
    # It is encoded as:
    # * ...
    # * -1: F (b)
    # * 0: C
    # * 1: G (#)
    # * 2: D (##)
    # * ...
    # TODO: convert digit to something readable
    attr_accessor :key

    # Octave. Default value is 0. 
    # It becomes 8 if the sheet is to be played one octave higher (8va).
    attr_accessor :octave

    # Table of midi channels. There are 4 ports and 16 channels, the channels are stored in this order:
    # port1/channel1  - port1/channel2 ... port1/channel16 - port2/channel1 ...
    # in array with the format:
    #   [[1,2,...16], [1,2,...16], [1,2,...16], [1,2,...16]]
    attr_accessor :channels

    # (Hash) Musical directions definitions. 
    # Each symbol is represented as the bar number at which it is placed.
    # If the symbol is not presented its value is nil.
    # There is full list of supported symbols in GuitarProHelper::MUSICAL_DIRECTIONS array (>= 5.0 only)
    attr_accessor :musical_directions

    # Selected master reverb setting (in Score information, value from 0 to 60) (>= 5.0 only)
    # TODO: Represent as names
    attr_accessor :master_reverb

    # Array of settings of bars. Doesn't represent bars as containers for notes (look at Bar class for it)
    attr_accessor :bars_settings

    # Array of tracks
    attr_accessor :tracks

    # Initializes new Song instance.
    # Parameters:
    # (String) +file_path+ Path to file to read. If is not specified default song instance will be created.
    # (Boolean) +headers_only+ Read only headers information from file if true (much faster than reading every note)
    def initialize(file_path = nil, headers_only = false)
      @version = 5.1
      @title = ''
      @title = ''
      @subtitle = ''
      @artist = ''
      @album = ''
      @lyricist = ''
      @composer = ''
      @copyright = ''
      @transcriber = ''
      @instructions = ''
      @notices = ''
      @triplet_feel = :no_triplet_feel
      @lyrics_track = 0
      @lyrics = []
      @master_volume = 100
      @equalizer = Array.new(11, 0)
      @page_setup = PageSetup.new
      @tempo = 'Moderate'
      @bpm = 120
      @key = 1
      @octave = 0
      @channels = []
      @musical_directions = Hash[GuitarProHelper::MUSICAL_DIRECTIONS.collect { |elem| [elem, nil] }]
      @master_reverb = 0
      @bars_settings = []
      @tracks = []

      # Read data from file if it is specified
      Reader.new(self, file_path, headers_only) unless file_path.nil?
    end

    def add_bar_settings
      @bars_settings << BarSettings.new
      @bars_settings.last
    end

    def add_track
      @tracks << Track.new
      @tracks.last
    end

    # Converts Song object to Hash
    # @return [Hash] song as a Hash
    def to_hash
      {
        'meta' => {
          'version' => version,
          'title' => title,
          'subtitle' => subtitle,
          'artist' => artist,
          'album' => album,
          'lyricist' => lyricist,
          'composer' => composer,
          'copyright' => copyright,
          'transcriber' => transcriber,
          'instructions' => instructions,
          'notices' => notices
        }
      }
    end

    # Converts Song object to JSON
    # @return [String] song as a JSON
    def to_json
      Oj.dump(to_hash)
    end

  end

end