module GuitarProParser

  # This class represents the content of Guitar Pro file.
  # It is initialized by path to .gp[3,4,5] file and automatically parse its data.
  #
  # == Attributes
  #
  # All attributes are read-only
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
  #
  
  class Song

    # Path to Guitar Pro file
    attr_reader :file_path

    # List of header's fields
    FIELDS = [:version, :title, :subtitle, :artist, :album, :lyricist, :composer, :copyright, 
              :transcriber, :instructions, :notices, :triplet_feel, :lyrics_track, :lyrics,
              :master_volume, :equalizer]

    # List of fields that couldn't be parsed as usual and have custom methods for parsing
    CUSTOM_METHODS = [:version, :lyricist, :notices, :triplet_feel, :lyrics_track, :lyrics, :master_volume, :equalizer]

    attr_reader *FIELDS

    def initialize file_path
      @file_path = file_path
      @offset = 0

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
      length = read_byte
      version_string = read_string length
      # TODO: Change a way to get value from string
      version_string['FICHIER GUITAR PRO v'] = ''
      @version = version_string.to_f

      # Skip first 31 bytes that are reserved for version data
      @offset = 31
    end

    def parse_lyricist
      parse :lyricist if @version > 5.0
    end

    def parse_notices
      @notices = []

      notices_count = read_integer
      notices_count.times do 
        notice = read_chunk
        @notices << notice
      end
    end

    def parse_triplet_feel
      if @version < 5.0
        value = read_byte
        @triplet_feel = !value.zero?
      end
    end

    def parse_lyrics_track
      @lyrics_track = read_integer if @version >= 4.0
    end

    def parse_lyrics
      if @version >= 4.0
        @lyrics = []
        
        5.times do 
          start_bar = read_integer
          length = read_integer
          lyrics_text = read_string length
          element = {text: lyrics_text, bar: start_bar}
          @lyrics << element
        end
      end
    end

    def parse_master_volume
      if @version >= 5.0
        @master_volume = read_integer 
        increment_offset 4
      end
    end

    def parse_equalizer
      if @version >= 5.0
        @equalizer = []
        11.times do
          value = read_byte
          @equalizer << value
        end
      end
    end


    def parse field
      value = read_chunk
      instance_variable_set("@#{field}", value)
    end

    def read_integer
      value = IO.binread(@file_path, 4, @offset).bytes.to_a[0].to_i
      increment_offset 4
      value
    end

    def read_byte
      value = IO.binread(@file_path, 1, @offset).bytes.to_a[0].to_i
      increment_offset 1
      value
    end

    def read_string length
      value = IO.binread(@file_path, length, @offset)
      increment_offset length
      value
    end

    def increment_offset delta
      @offset = @offset + delta
    end

    # Reads data chunk from file.
    #
    # Chunk's format is:
    # 4 bytes - field length (including string length byte that follows this value)
    # 1 byte  - string length (N)
    # N bytes - string
    def read_chunk
      field_length = read_integer
      string_length = read_byte
      read_string string_length
    end

  end

end