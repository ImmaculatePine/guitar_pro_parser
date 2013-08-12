module GuitarProParser

  class Beat

    attr_accessor :dotted,
                  :mix_table,
                  :rest,
                  :duration,
                  :tuplet,
                  :chord_diagram,
                  :text,
                  :effects,
                  :strings,
                  :transpose,
                  :extra_byte_after_transpose
    
    def initialize
      # Initialize attributes by default values
      @dotted = false
      @mix_table = nil
      @rest = nil
      
      @duration = :eighth
      @tuplet = nil
      @chord_diagram = nil
      @text = nil
      @effects = {}
      @strings = {}

      @transpose = nil
      @extra_byte_after_transpose = false
    end

    def has_effect?(effect)
      @effects.include?(effect)
    end

    def add_effect(effect)
      @effects[effect] = nil
    end

  end

end