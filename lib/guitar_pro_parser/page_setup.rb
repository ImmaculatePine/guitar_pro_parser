module GuitarProParser

  class PageSetup

    attr_accessor :page_format_length, :page_format_width, :left_margin, :right_margin, :top_margin, :bottom_margin, :score_size,
                  :title, :subtitle, :artist, :album, :lyrics_author, :music_author, :lyrics_and_music_author,
                  :copyright_line_1, :copyright_line_2, :page_number, :displayed_fields

    def initialize
      @page_format_length = 0
      @page_format_width = 0
      @left_margin = 0
      @right_margin = 0
      @top_margin = 0
      @bottom_margin = 0
      @score_size = 0

      @title = ''
      @subtitle = ''
      @artist = ''
      @album = ''
      @lyrics_author = ''
      @music_author = ''
      @lyrics_and_music_author = ''
      @copyright_line_1 = ''
      @copyright_line_2 = ''
      @page_number = ''

      @displayed_fields = []
    end

  end

end