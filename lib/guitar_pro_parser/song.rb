module GuitarProParser

  require "guitar_pro_parser/parser"
  require "guitar_pro_parser/page_setup"
  require "guitar_pro_parser/bar"
  require "guitar_pro_parser/track"

  # This class represents the content of Guitar Pro file.
  # It is initialized by path to .gp[3,4,5] file and automatically parse its data.
  #
  # == Attributes
  #
  # All attributes are read-only
  #
  # * +file_path+     (string)  Path to Guitar Pro file
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
  # * +tempo+         (string)  (>= 5.0 only)
  # * +bpm+           (integer) Tempo as beats per minute
  # * +key+           (integer) #TODO: convert digit to something readable (has different format for GP3 and GP4/5)
  # * +octave+        (integer) (>= 4.0 only)
  # * +midi_channels+ (array)   Table of midi channels. There are 4 ports and 16 channels, the channels are stored in this order: 
  #                             port1/channel1  - port1/channel2 ... port1/channel16 - port2/channel1 ...
  # * +directions_definitions+ (hash) Hash of musical directions definitions. 
  #                                   Each symbol is represented as the bar number at which the it is placed.
  #                                   If the symbol is not presented its value is nil.
  #                                   There is full list of supported symbols in DIRECTIONS_DEFINITIONS array (>= 5.0 only)
  # * +master_reverb+  (integer) Selected master reverb setting (in Score information, value from 0 to 60) (>= 5.0 only) #TODO represent as names
  # * +bars_count+     (integer) Count of bars (measures)
  # * +tracks_count+   (integer) Count of tracks
  # * +bars+           (array)   Array of Bar class objects
  # * +tracks+         (array)   Array of Track class objects
  #
  
  class Song

    # Path to Guitar Pro file
    attr_reader :file_path

    # List of header's fields
    FIELDS = [:version, :title, :subtitle, :artist, :album, :lyricist, :composer, :copyright, 
              :transcriber, :instructions, :notices, :triplet_feel, :lyrics_track, :lyrics,
              :master_volume, :equalizer, :page_setup, :tempo, :bpm, :key, :octave, :midi_channels,
              :directions_definitions, :master_reverb, :bars_count, :tracks_count,
              :bars, :tracks]

    # List of fields that couldn't be parsed as usual and have custom methods for parsing
    CUSTOM_METHODS = [:version, :lyricist, :notices, :triplet_feel, :lyrics_track, :lyrics, 
                      :master_volume, :equalizer, :page_setup, :tempo, :bpm, :key, :octave,
                      :midi_channels, :directions_definitions, :master_reverb, :bars_count, :tracks_count,
                      :bars, :tracks]

    attr_reader *FIELDS

    # TODO rename to musical_directions
    DIRECTIONS_DEFINITIONS = [:coda, :double_coda, :segno, :segno_segno, :fine, :da_capo,
                              :da_capo_al_coda, :da_capo_al_double_coda, :da_capo_al_fine,
                              :da_segno, :da_segno_al_coda, :da_segno_al_double_coda,
                              :da_segno_al_fine, :da_segno_segno, :da_segno_segno_al_coda,
                              :da_segno_segno_al_double_coda, :da_segno_segno_al_fine,
                              :da_coda, :da_double_coda]

    def initialize file_path
      @file_path = file_path
      @parser = Parser.new @file_path

      FIELDS.each do |field|
        if CUSTOM_METHODS.include? field
          send "parse_#{field.to_s}"
        else
          parse field
        end
      end
    end

  private

    def parse_version
      length = @parser.read_byte
      version_string = @parser.read_string length
      # TODO: Change a way to get value from string
      version_string['FICHIER GUITAR PRO v'] = ''
      @version = version_string.to_f

      # Skip first 31 bytes that are reserved for version data
      @parser.offset = 31
    end

    def parse_lyricist
      parse :lyricist if @version > 5.0
    end

    def parse_notices
      @notices = []

      notices_count = @parser.read_integer
      notices_count.times do 
        @notices << @parser.read_chunk
      end
    end

    def parse_triplet_feel
      if @version < 5.0
        value = @parser.read_byte
        @triplet_feel = !value.zero?
      end
    end

    def parse_lyrics_track
      @lyrics_track = @parser.read_integer if @version >= 4.0
    end

    def parse_lyrics
      if @version >= 4.0
        @lyrics = []

        5.times do 
          start_bar = @parser.read_integer
          length = @parser.read_integer
          lyrics_text = @parser.read_string length
          @lyrics << {text: lyrics_text, bar: start_bar}
        end
      end
    end

    def parse_master_volume
      if @version >= 5.0
        @master_volume = @parser.read_integer 
        @parser.skip_integer
      end
    end

    def parse_equalizer
      if @version >= 5.0
        @equalizer = []
        11.times do
          @equalizer << @parser.read_byte
        end
      end
    end

    def parse_page_setup
      @page_setup = PageSetup.new @parser if @version >= 5.0
    end

    def parse_tempo
      @tempo = @parser.read_chunk if @version >= 5.0
    end

    def parse_bpm
      @bpm = @parser.read_integer
      @parser.skip_byte if @version >= 5.0
    end

    def parse_key
      if @version >= 4.0
        @key = @parser.read_byte
        3.times { @parser.skip_byte }
      else
        @key = @parser.read_integer
      end
    end

    def parse_octave
      if @version >= 4.0
        @octave = @parser.read_byte
      end
    end

    # TODO
    def parse_midi_channels
      @midi_channels = []
      64.times do
        @parser.skip_integer
        6.times { @parser.skip_byte}
        @parser.skip_short_integer
        @midi_channels << nil
      end
    end

    def parse_directions_definitions
      if @version >= 5.0
        @directions_definitions = {}
        DIRECTIONS_DEFINITIONS.each do |definition|
          value = @parser.read_short_integer
          value = nil if value == 255
          @directions_definitions[definition] = value
        end
      end      
    end

    def parse_master_reverb
      @master_reverb = @parser.read_integer if @version >= 5.0
    end

    def parse_bars_count
      @bars_count = @parser.read_integer
    end

    def parse_tracks_count
      @tracks_count = @parser.read_integer
    end

    def parse_bars
      @bars = []
      @bars_count.times do |i|
        @bars << (Bar.new @parser, self, i)
      end
    end

    def parse_tracks
      @tracks = []
      @tracks_count.times do |i|
        @tracks << (Track.new @parser, self, i)
      end

      # Padding
      @parser.skip_byte if @version >= 5.0
    end

    def parse field
      value = @parser.read_chunk
      instance_variable_set("@#{field}", value)
    end

  end

end