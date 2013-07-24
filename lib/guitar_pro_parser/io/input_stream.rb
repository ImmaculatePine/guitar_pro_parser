module GuitarProParser

  class InputStream

    INTEGER_LENGTH = 4
    SHORT_INTEGER_LENGTH = 2
    BYTE_LENGTH = 1

    attr_accessor :offset

    def initialize file_path
      @file_path = file_path
      @offset = 0
    end

    # Reads unsigned integer (4 bytes)
    def read_integer
      value = IO.binread(@file_path, INTEGER_LENGTH, @offset).unpack('i')[0]
      skip_integer
      value
    end

    # Reads signed integer (4 bytes)
    def read_signed_integer
      value = IO.binread(@file_path, INTEGER_LENGTH, @offset).unpack('I')[0]
      skip_integer
      value
    end

    # Reads unsigned short integer (2 bytes)
    def read_short_integer
      value = IO.binread(@file_path, SHORT_INTEGER_LENGTH, @offset).unpack('S_')[0]
      skip_short_integer
      value
    end

    # Reads signed short integer (2 bytes)
    def read_signed_short_integer
      value = IO.binread(@file_path, SHORT_INTEGER_LENGTH, @offset).unpack('s_')[0]
      skip_short_integer
      value
    end

    # Reads unsigned byte (8 bits) (0..255)
    def read_byte
      value = IO.binread(@file_path, BYTE_LENGTH, @offset).unpack('C')[0]
      skip_byte
      value
    end

    # Reads signed byte (8 bits) (-127..127)
    def read_signed_byte
      value = IO.binread(@file_path, BYTE_LENGTH, @offset).unpack('c')[0]
      skip_byte
      value
    end
    
    # Reads signed byte as boolean (8 bit)
    def read_boolean
      !read_byte.zero?
    end

    # Reads string with specified length
    def read_string(length)
      value = IO.binread(@file_path, length, @offset)
      increment_offset(length)
      value
    end

    # Reads byte as 8-bit bitmask
    def read_bitmask
      bits = []
      value = read_byte
      value.to_s(2).each_char { |bit| bits << !bit.to_i.zero? }
      bits.reverse!
      bits << false while bits.count < 8
      bits
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