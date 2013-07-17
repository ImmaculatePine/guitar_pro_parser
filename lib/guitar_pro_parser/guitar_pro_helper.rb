module GuitarProHelper

  # Macros to create boolean instance variables' getters like this:
  #   attr_boolean :complete
  # generates
  #   complete?
  # method that returns @complete instance variable
  def attr_boolean(*variables)
    variables.each do |variable|
      define_method("#{variable}?") do
        send("@#{variable}")
      end
    end
  end

  # Converts note's digit representation to its string equivalent:
  # 0 for C0, 1 for C#0, etc.
  def digit_to_note digit
    notes = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    note_index = 0
    octave = 0
    digit.times do |i|
      note_index = note_index + 1
      if note_index == notes.count
        note_index = 0
        octave = octave + 1
      end
    end

    "#{notes[note_index]}#{octave.to_s}"
  end

  # TODO: Create helper to convert number of increments of .1dB to float for equalizers
  
end