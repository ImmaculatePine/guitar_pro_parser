module GuitarProParser

  require 'guitar_pro_parser/guitar_pro_helper'
  
  # This class represents bars as containers of notes.
  #
  # == Attributes
  #
  # All attributes are read-only
  #
  # * +voices+     (hash)  Voices of this bar.
  #                        Guitar Pro 5 files has :lead and :bass voices.
  #                        Guitar Pro 4 and less files has only :lead voice.
  #
  #
  class Bar

    attr_accessor :voices

    def initialize(version, settings)
      @settings = settings
      @voices = {}
      voices_count = version >= 5.0 ? 2 : 1
      voices_count.times { |n| @voices[VOICES.fetch(n)] = [] }
    end

    # Returns selected beat of selected voice
    def get_beat(number, voice = :lead)
      @voices.fetch(voice).fetch(number)
    end

  end

end