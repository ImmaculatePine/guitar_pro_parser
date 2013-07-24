require 'guitar_pro_parser/io/reader'

module GuitarProParser
  
  # This class represents the content of Guitar Pro file.
  # It can be initialized by path to .gp[3,4,5] file. The it will automatically parse its data.
  # Or it can be just instantiated with default values of the attributes.
  #
  # == Attributes
  #
  #
  # * +version+       (float)   Version of Guitar Pro
  # * +title+         (string)
  # * +subtitle+      (string)
  # * +artist+        (string)
  # * +album+         (string)
  # * +lyricist+      (string)  Author of lyrics (>= 5.0 only)
  # * +composer+      (string)  Author of music
  # * +copyright+     (string)
  # * +transcriber+   (string)  Author of tabulature
  # * +instructions+  (string)
  # * +notices+       (array)   Array of notices (each notice is a string)
  # * +triplet_feel+  (boolean) Shuffle rhythm feel (< 5.0 only)
  # * +lyrics_track+  (integer) Associated track for the lyrics (>= 4.0 only)
  # * +lyrics+        (array)   Lyrics data represented as array of hashes with 5 elements
  #                             (for lyrics lines from 1 to 5). Each line has lyrics' text 
  #                             and number of bar where it starts: {text: "Some text", bar: 1}
  #                             (>= 4.0 only)
  # * +master_volume+ (integer) Master volume (value from 0 - 200, default is 100) (>= 5.0 only)
  # * +equalizer+     (array)   Array of equalizer settings. 
  #                             Each one is represented as number of increments of .1dB the volume for 
  #                             32Hz band is lowered
  #                             60Hz band is lowered
  #                             125Hz band is lowered
  #                             250Hz band is lowered
  #                             500Hz band is lowered
  #                             1KHz band is lowered
  #                             2KHz band is lowered
  #                             4KHz band is lowered
  #                             8KHz band is lowered
  #                             16KHz band is lowered
  #                             overall volume is lowered (gain)
  # * +page_setup+    (object)  Object of PageSetup class that contains data about page setup (>= 5.0 only)
  # * +tempo+         (string)  Tempo as string
  # * +bpm+           (integer) Tempo as beats per minute
  # * +key+           (integer) #TODO: convert digit to something readable (has different format for GP3 and GP4/5)
  # * +octave+        (integer) (>= 4.0 only)
  # * +channels+      (array)   Table of midi channels. There are 4 ports and 16 channels, the channels are stored in this order: 
  #                             port1/channel1  - port1/channel2 ... port1/channel16 - port2/channel1 ...
  # * +musical_directions+ (hash) Hash of musical directions definitions. 
  #                               Each symbol is represented as the bar number at which it is placed.
  #                               If the symbol is not presented its value is nil.
  #                               There is full list of supported symbols in GuitarProHelper::MUSICAL_DIRECTIONS array (>= 5.0 only)
  # * +master_reverb+  (integer) Selected master reverb setting (in Score information, value from 0 to 60) (>= 5.0 only) #TODO represent as names
  # * +bars_settings+  (array)   Array of settings of bars. Doesn't represent bars as containers for notes (look at Bar class for it)
  # * +tracks+         (array)   Array of tracks
  #
  class Song

    include GuitarProHelper

    attr_accessor :version, :title, :subtitle, :artist, :album, :lyricist, :composer, :copyright, 
                  :transcriber, :instructions, :notices, :triplet_feel, :lyrics_track, :lyrics,
                  :master_volume, :equalizer, :page_setup, :tempo, :bpm, :key, :octave, :channels,
                  :musical_directions, :master_reverb, :bars_settings, :tracks

    def initialize(file_path = nil, headers_only = false)
      # Initialize variables by default values
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

      # Read data from file
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

  end

end