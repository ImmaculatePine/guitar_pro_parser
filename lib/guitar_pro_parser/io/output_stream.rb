module GuitarProParser

  class OutputStream

    def initialize file_path
      @file_path = file_path
      @buffer = ''
    end

    def close
      IO.write(@file_path, @buffer)
    end

    def write_to_buffer(value)
      @buffer = @buffer + value
    end

    def write_integer(*value)
      write_to_buffer(value.pack('I'))
    end

    def write_signed_integer(*value)
      write_to_buffer(value.pack('i'))
    end

    def write_short_integer(*value)
      write_to_buffer(value.pack('S_'))
    end

    def write_signed_short_integer(*value)
      write_to_buffer(value.pack('s_'))
    end

    def write_byte(*value)
      write_to_buffer(value.pack('C'))
    end

    def write_signed_byte(*value)
      write_to_buffer(value.pack('c'))
    end
    
    def write_boolean(value)
      write_byte(value ? 1 : 0)
    end

    def write_bitmask(value)
      binary = ''
      value.reverse!
      value.each { |bit| binary += bit ? '1' : '0'}
      digit = binary.to_i(2)
      write_byte(digit)
    end

    # Writes data chunk to file.
    #
    # Chunk's format is:
    # 4 bytes - field length (including string length byte that follows this value)
    # 1 byte  - string length (N)
    # N bytes - string
    def write_chunk(value)
      write_integer(value.length + 1)
      write_byte(value.length)
      write_string(value)
    end

    def write_padding(size)
      size.times { write_byte(0) }
    end

    private

    def write_string(value)
      write_to_buffer(value)
    end

  end

end