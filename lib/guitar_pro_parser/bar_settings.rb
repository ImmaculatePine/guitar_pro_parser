module GuitarProParser

  # This class represents settings of bars (measures).
  #
  # == Attributes
  #
  # * +new_time_signature+                  (hash)      Info about new time signature in format 
  #                                                     { numerator: 4, denominator: 4, beam_eight_notes_by_values: [2, 2, 2, 2] }
  #                                                     or nil if doesn't present
  #
  # * +has_start_of_repeat+                 (boolean)   Is there start of repeat symbol?
  # * +has_end_of_repeat+                   (boolean)   Is there end of repeat symbol?
  # * +repeats_count+                       (integer)   Denominator of time signature if @has_end_of_repeat presents  
  # * +alternate_endings+                   (array)     Contains numbers of all alternate endings in Guitar Pro 5 
  #                                                     or the largest number of alternate endings in Guitar Pro 4 or less
  #
  # * +marker+                              (hash)      Info about marker in format:
  #                                                     { name: "Marker name", color: [255, 0, 0] }
  #                                                     or nil if doesn't present
  #
  # * +new_key_signature+                   (hash)      Info about new key signature in format:
  #                                                     { key: 0, scale: :major }
  #                                                     or nil if doesn't present.
  #                                                     Key is encoded like this: # TODO: Convert to more readable format
  #                                                       -2   Bb (bb)
  #                                                       -1   F  (b)
  #                                                        0   C
  #                                                        1   G  (#)
  #                                                        2   D  (##)
  #                                                     Scale can be :major or :minor
  #
  # * +triplet_feel+                        (symbol)   Can be :no_triplet_feel, :triplet_8th or :triplet_16th
  # * +double_bar+                          (boolean)  Is this bar double?
  #
  class BarSettings

    attr_accessor :new_time_signature,
                  :has_start_of_repeat,
                  :has_end_of_repeat,
                  :repeats_count,
                  :alternate_endings,
                  :marker,
                  :new_key_signature,
                  :triplet_feel,
                  :double_bar

    def initialize
      # Initialize attributes by default values
      @new_time_signature = nil
      @has_start_of_repeat = false
      @has_end_of_repeat = false
      @repeats_count = 0
      @alternate_endings = []
      @marker = nil
      @new_key_signature = nil
      @triplet_feel = :no_triplet_feel
      @double_bar = false
    end

    def set_new_key_signature(key, scale)
      @new_key_signature = { key: key, scale: scale }
    end

    def set_new_time_signature(numerator, denominator, beam_eight_notes_by_values)
      @new_time_signature = { numerator: numerator, denominator: denominator, beam_eight_notes_by_values: beam_eight_notes_by_values }
    end

    def set_marker(name, color)
      @marker = { name: name, color: color }
    end

  end

end