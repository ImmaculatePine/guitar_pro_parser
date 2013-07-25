module GuitarProParser
  
  # This class represents bars as containers of notes.
  #
  class Bar

    # Hash of voices of this bar.
    # Guitar Pro 5 files has :lead and :bass voices.
    # Guitar Pro 4 and less files has only :lead voice.
    # Each voice is array of beats.
    attr_accessor :voices

    def initialize
      @voices = {lead: [], bass: []}
    end

    # Returns selected beat of selected voice
    def get_beat(number, voice = :lead)
      @voices.fetch(voice).fetch(number)
    end

  end

end