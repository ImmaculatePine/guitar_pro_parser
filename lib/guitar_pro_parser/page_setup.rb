module GuitarProParser

  # The enabled header/footer fields bitmask declares which fields are displayed:
  # Bit 0 (LSB):  Title field
  # Bit 1:    Subtitle field
  # Bit 2:    Artist field
  # Bit 3:    Album field
  # Bit 4:    Words (Lyricist) field
  # Bit 5:    Music (Composer) field
  # Bit 6:    Words & Music field
  # Bit 7:    Copyright field
  # Bit 8:    Page Number (field)
  # Bits 9 - 15:  Unused (set to 0)

  class PageSetup

    FIELDS = [:page_format_length, :page_format_width, :left_margin, :right_margin, :top_margin, :bottom_margin, :score_size,
              :fields_bitmask,
              :title, :subtitle, :artist, :album, :lyrics_author, :music_author, :lyrics_and_music_author, :copyright_line_1, :copyright_line_2, :page_number]
    attr_reader *FIELDS

    READ_AS_INTEGER = [:page_format_length, :page_format_width, :left_margin, :right_margin, :top_margin, :bottom_margin, :score_size]
    READ_AS_SHORT_INTEGER = [:fields_bitmask]

    def initialize parser
      @parser = parser

      FIELDS.each do |field|
        if READ_AS_INTEGER.include? field
          instance_variable_set("@#{field}", @parser.read_integer)
        elsif READ_AS_SHORT_INTEGER.include? field
          parse_fields_bitmask
        else
          instance_variable_set("@#{field}", @parser.read_chunk)
        end
      end
    end

    def parse_fields_bitmask
      @parser.skip_short_integer
      @fields_bitmask = []
      16.times do 
        @fields_bitmask << 0 # TODO
      end
    end

  end

end