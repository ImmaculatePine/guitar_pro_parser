module GuitarProParser
  class Parser

    attr_accessor :offset

    def initialize file_path
      @file_path = file_path
      @offset = 0
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

    # Reads data chunk from file.
    #
    # Chunk's format is:
    # 4 bytes - field length (including string length byte that follows this value)
    # 1 byte  - string length (N)
    # N bytes - string
    def read_chunk
      increment_offset 4
      string_length = read_byte
      read_string string_length
    end

    def increment_offset delta
      @offset = @offset + delta
    end
  end
end