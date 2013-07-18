module GuitarProParser

  class Bar

    attr_accessor :beats

    def initialize(settings)
      @settings = settings
      @beats = []
    end

  end

end