module GuitarProHelper

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

  # TODO Create helper to convert number of increments of .1dB to float for equalizers
  
end