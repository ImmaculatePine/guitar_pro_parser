module GuitarProHelper

  NOTES = %w(C C# D D# E F F# G G# A A# B)
  VOICES = [:lead, :bass]
  FINGERS = [:thumb, :index, :middle, :ring, :pinky]
  BEND_TYPES = [:none, :bend, :bend_and_release, :bend_release_bend, :prebend, :prebend_and_release,
                :tremolo_dip, :tremolo_dive, :tremolo_release_up, :tremolo_inverted_dip, :tremolo_return, :tremolo_release_down]
  VIBRATO_TYPES = [:none, :fast, :average, :slow]
  MUSICAL_DIRECTIONS = [:coda, :double_coda, :segno, :segno_segno, :fine, :da_capo,
                      :da_capo_al_coda, :da_capo_al_double_coda, :da_capo_al_fine,
                      :da_segno, :da_segno_al_coda, :da_segno_al_double_coda,
                      :da_segno_al_fine, :da_segno_segno, :da_segno_segno_al_coda,
                      :da_segno_segno_al_double_coda, :da_segno_segno_al_fine,
                      :da_coda, :da_double_coda]
  TRIPLET_FEEL = [:no_triplet_feel, :triplet_8th, :triplet_16th]

  # Macros to create boolean instance variables' getters like this:
  #   attr_boolean :complete
  # generates
  #   complete?
  # method that returns @complete instance variable
  def attr_boolean(*variables)
    variables.each do |variable|
      define_method("#{variable}?") do
        instance_variable_get("@#{variable}")
      end
    end
  end

  # Converts note's digit representation to its string equivalent:
  # 0 for C0, 1 for C#0, etc.
  def digit_to_note(digit)
    note_index = 0
    octave = 0
    digit.times do |i|
      note_index = note_index + 1
      if note_index == NOTES.count
        note_index = 0
        octave = octave + 1
      end
    end

    "#{NOTES.fetch(note_index)}#{octave.to_s}"
  end

  def parse_bend(parser)
    type = BEND_TYPES.fetch(parser.read_byte)
    height = parser.read_integer
    points_coint = parser.read_integer
    result = { type: type, height: height, points: [] }
    points_coint.times do
      time = parser.read_integer
      pitch_alteration = parser.read_integer
      vibrato_type = VIBRATO_TYPES.fetch(parser.read_byte)
      result[:points] << { time: time, pitch_alteration: pitch_alteration, vibrato_type: vibrato_type }
    end

    result
  end

  # TODO: Create helper to convert number of increments of .1dB to float for equalizers
  
end