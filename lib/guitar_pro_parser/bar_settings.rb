module GuitarProParser

  # This class represents settings of bars (measures).
  #
  # == Attributes
  # All attributes are read-only
  #
  # * +time_signature_change_numenator+     (boolean)  Is there new time signature numerator?
  # * +time_signature_change_denomenator+   (boolean)  Is there new time signature denomerator?
  # * +has_start_of_repeat+                 (boolean)  Is there start of repeat symbol?
  # * +has_end_of_repeat+                   (boolean)  Is there end of repeat symbol?
  # * +has_number_of_alternate_ending+      (boolean)  Is there number of alternate ending?
  # * +has_marker+                          (boolean)  Is there marker in this bar?
  # * +key_signature_change+                (boolean)  Is key signature changed in this bar?
  # * +double_bar+                          (boolean)  Is this bar double?
  #
  # * +time_signature_numenator+            (integer)  Numenator of time signature if @time_signature_change_numenator presents
  # * +time_signature_change_denomenator+   (integer)  Denomenator of time signature if @time_signature_change_denomenator presents
  # * +repeats_count+                       (integer)  Denomenator of time signature if @has_end_of_repeat presents
  # * +number_of_alternate_ending+          (array)    If @has_number_of_alternate_ending this arary contains
  #                                                    numbers of all alternate endings in Guitar Pro 5 
  #                                                    or
  #                                                    the largest number of alternate endings in Guitar Pro 4 or less
  # * +marker_name+                          (string)  Name of the marker if @has_marker
  # * +marker_color+                         (array)   Array of RGB values for marker color if @has_marker. E.g. [255, 0, 0] for red
  # * +key+                                  (integer) Key signature if @key_signature_change. It encoded like this: # TODO convert to more readable format
  #                                                    -2  Bb (bb)
  #                                                    -1  F  (b)
  #                                                    0   C
  #                                                    1   G  (#)
  #                                                    2   D  (##)
  # * +scale+                                (symbol)  Key signature scale (:major or :minor) if @key_signature_change
  # * +beam_eight_notes_by_values+           (array)   How to beam 8th notes if time signature was changed. E.g. 2 + 2 + 2 + 2 = 8
  # * +triplet_feel+                         (symbol)  Can be :no_triplet_feel, :triplet_8th or :triplet_16th

  class BarSettings

    BITMASK = [:time_signature_change_numenator,
               :time_signature_change_denomenator,
               :has_start_of_repeat,
               :has_end_of_repeat,
               :has_number_of_alternate_ending,
               :has_marker,
               :key_signature_change,
               :double_bar]
    
    attr_reader *BITMASK
    attr_reader :time_signature_numenator,
                :time_signature_denomenator,
                :repeats_count,
                :number_of_alternate_ending,
                :marker_name,
                :marker_color,
                :key,
                :scale,
                :beam_eight_notes_by_values,
                :triplet_feel

    TRIPLET_FEEL = [:no_triplet_feel, :triplet_8th, :triplet_16th]

    def initialize parser, version, number
      @parser = parser
      @version = version

      # The bar bitmask declares which parameters are defined for the bar:
      # Bit 0 (LSB):  Time signature change numerator (GP version >= 3), or start of repeat (GP version < 3)
      # Bit 1:        Time signature change denominator (GP version >= 3), or end of repeat (GP version < 3)
      # Bit 2:        Start of repeat (GP version >= 3), number of alternative ending (GP version < 3)
      # Bit 3:        End of repeat (GP version >= 3)
      # Bit 4:        Number of alternate ending (GP version >= 3)
      # Bit 5:        Marker precense
      # Bit 6:        Key signature change
      # Bit 7 (MSB):  Double bar
      bits = @parser.read_bitmask
      bits.count.times do |i|
        variable_name = "@#{BITMASK[i].to_s}"
        instance_variable_set(variable_name, bits[i])
      end

      # Read time signature num and den if they present
      @time_signature_numenator = @parser.read_byte if @time_signature_change_numenator
      @time_signature_denomenator = @parser.read_byte if @time_signature_change_denomenator

      # Read count of repeats if there is end of repeat
      if @has_end_of_repeat
        @repeats_count = @parser.read_byte 

        # Version 5 of the format has slightly different counting for repeats
        @repeats_count = @repeats_count - 1 if @version >= 5.0
      end

      # Read number of alternate ending and marker
      # Their order differs depending on Guitar Pro version
      if @version < 5.0
        parse_number_of_alternate_ending
        parse_marker
      else
        parse_marker
        parse_number_of_alternate_ending
      end

      # Read new key signature if it changed
      if @key_signature_change
        @key = @parser.read_byte
        if @parser.read_boolean
          @scale = :minor
        else
          @scale = :major
        end
      end

      # Read specific Guitar Pro 5 data
      if @version >= 5.0

        # Read beaming 8th notes by values if there is new time signature
        if @time_signature_change_numenator || @time_signature_change_denomenator
          @beam_eight_notes_by_values = []
          4.times do
            @beam_eight_notes_by_values << @parser.read_byte
          end
        end

        # If a GP5 file doesn't define an alternate ending here, ignore a byte of padding
        @parser.skip_byte unless @has_number_of_alternate_ending
        
        # Read triplet feel
        # It is represented as:
        # * 0 - no triplet feel
        # * 1 - triplet 8th
        # * 2 - triplet 16th
        @triplet_feel = TRIPLET_FEEL[@parser.read_byte]
        
        # Skip byte of padding
        @parser.skip_byte
      end
    end

    private

    def parse_marker
      if @has_marker
        # Read marker name
        @marker_name = @parser.read_chunk

        # Read marker color as array of RGB values
        @marker_color = []
        3.times do
          @marker_color << @parser.read_byte
        end

        # Skip padding byte
        @parser.skip_byte
      end
    end

    def parse_number_of_alternate_ending
      if @has_number_of_alternate_ending
        # In Guitar Pro 5 values is bitmask for creating array of alternate endings
        # Bit 0 - alt. ending #1
        # Bit 1 - alt. ending #2
        # ...
        # Bit 7 - alt. ending #8
        #
        # In Guitar Pro 4 and less value is a digit.
        #
        # Anyway @number_of_alternate_ending is represented as array
        @number_of_alternate_ending = []
        if (@version >= 5.0)
          bits = @parser.read_bitmask
          bits.count.times do |i|
            @number_of_alternate_ending << (i+1) if bits[i]
          end
        else
            @number_of_alternate_ending << @parser.read_byte
        end
      end

    end

  end

end