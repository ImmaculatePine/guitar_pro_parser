module GuitarProParser

  class Parser

    INTEGER_LENGTH = 4
    SHORT_INTEGER_LENGTH = 2
    BYTE_LENGTH = 1

    attr_accessor :offset

    def self.to_bitmask(n, as = :digits, length = 8)
      bits = []
      
      n.to_s(2).each_char { |bit| bits << bit.to_i }
      bits = bits.reverse
      bits << 0 while bits.count < length

      if as == :booleans
        booleans = []
        bits.each { |bit| booleans << !bit.zero? }
        booleans
      else
        bits
      end
    end

    def initialize file_path
      @file_path = file_path
      @offset = 0
    end

    def read_integer
      value = IO.binread(@file_path, INTEGER_LENGTH, @offset).bytes.to_a[0].to_i
      skip_integer
      value
    end

    def read_short_integer
      value = IO.binread(@file_path, SHORT_INTEGER_LENGTH, @offset).bytes.to_a[0].to_i
      skip_short_integer
      value
    end

    def read_byte
      value = IO.binread(@file_path, BYTE_LENGTH, @offset).bytes.to_a[0].to_i
      skip_byte
      value
    end

    def read_boolean
      !read_byte.zero?
    end

    def read_string length
      value = IO.binread(@file_path, length, @offset)
      increment_offset(length)
      value
    end

    # Reads data chunk from file.
    #
    # Chunk's format is:
    # 4 bytes - field length (including string length byte that follows this value)
    # 1 byte  - string length (N)
    # N bytes - string
    def read_chunk
      skip_integer
      string_length = read_byte
      read_string string_length
    end

    def increment_offset delta
      @offset = @offset + delta
    end

    def skip_integer
      increment_offset(INTEGER_LENGTH)
    end

    def skip_short_integer
      increment_offset(SHORT_INTEGER_LENGTH)
    end

    def skip_byte
      increment_offset(BYTE_LENGTH)
    end

  end
  
end