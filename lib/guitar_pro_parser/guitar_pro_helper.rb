module GuitarProHelper

  # Possible versions of Guitar Pro file
  VERSIONS = { 'FICHIER GUITARE PRO v1' => 1.0,
               'FICHIER GUITARE PRO v1.01' => 1.01,
               'FICHIER GUITARE PRO v1.02' => 1.02,
               'FICHIER GUITARE PRO v1.03' => 1.03,
               'FICHIER GUITARE PRO v1.04' => 1.04,
               'FICHIER GUITAR PRO v2.20'  => 2.2,
               'FICHIER GUITAR PRO v2.21'  =>2.21,
               'FICHIER GUITAR PRO v3.00' => 3.0,
               'FICHIER GUITAR PRO v4.00' => 4.0,
               'FICHIER GUITAR PRO v4.06' => 4.06,
               'FICHIER GUITAR PRO L4.06' => 4.06,
               'FICHIER GUITAR PRO v5.10' => 5.1 }

  NOTES = %w(C C# D D# E F F# G G# A A# B)
  VOICES = [:lead, :bass]
  FINGERS = [:thumb, :index, :middle, :ring, :pinky]
  BEND_TYPES = [:none, :bend, :bend_and_release, :bend_release_bend, :prebend, :prebend_and_release,
                :tremolo_dip, :tremolo_dive, :tremolo_release_up, :tremolo_inverted_dip, :tremolo_return, :tremolo_release_down]
  BEND_VIBRATO_TYPES = [:none, :fast, :average, :slow]
  MUSICAL_DIRECTIONS = [:coda, :double_coda, :segno, :segno_segno, :fine, :da_capo,
                      :da_capo_al_coda, :da_capo_al_double_coda, :da_capo_al_fine,
                      :da_segno, :da_segno_al_coda, :da_segno_al_double_coda,
                      :da_segno_al_fine, :da_segno_segno, :da_segno_segno_al_coda,
                      :da_segno_segno_al_double_coda, :da_segno_segno_al_fine,
                      :da_coda, :da_double_coda]
  TRIPLET_FEEL = [:no_triplet_feel, :triplet_8th, :triplet_16th]
  REST_TYPES = { '0' => :empty_beat, 
                 '2' => :rest }
  DURATIONS = { '-2' => :whole,
                '-1' => :half,
                 '0' => :quarter,
                 '1' => :eighth,
                 '2' => :sixteens,
                 '3' => :thirty_second,
                 '4' => :sixty_fourth }
  STRING_EFFECTS = [:tremolo_bar, :tapping, :slapping, :popping]
  STROKE_EFFECT_SPEEDS = [:none, 128, 64, 32, 16, 8, 4]
  STROKE_DIRECTIONS = [:none, :up, :down]
  NOTE_TYPES = [:normal, :tie, :dead]
  NOTE_DYNAMICS = %w(ppp pp p mp mf f ff fff)
  GRACE_NOTE_TRANSITION_TYPES = [:none, :slide, :bend, :hammer]
  GRACE_NOTE_DURATIONS = { '3' => 16, '2' => 32, '1' => 64 }
  TREMOLO_PICKING_SPEEDS = { '3' => 32, '2' => 16, '1' => 8 }
  
  SLIDE_TYPES = [:no_slide, :shift_slide, :legato_slide, :slide_out_and_downwards, :slide_out_and_upwards, :slide_in_from_below, :slide_in_from_above]
  MAP_SLIDE_TYPES_GP5 = { '0'=>0, '1'=>1, '2'=>2, '4'=>3, '8'=>4, '16'=>5, '32'=>6 }
  MAP_SLIDE_TYPES_GP4 = { '-2'=>6, '-1'=>5, '0'=>0, '1'=>1, '2'=>2, '3'=>3, '4'=>4 }

  HARMONIC_TYPES = [:none, :natural, :artificial, :tapped, :pinch, :semi]
  TRILL_PERIODS = { '1' => 4, '2' => 8, '3' => 16 }
  CHORD_TYPES = %w(M 7 7M 6 m m7 m7M m6 sus2 sus4 7sus2 7sus4 dim aug 5)
  NINE_ELEVEN_THIRTEEN = [0, 9, 11, 13]

  # Strange moment here. In format specification is written:
  #   0: perfect
  #   1: augmented
  #   2: diminished
  # But actually (after tests) it seems to be:
  #   0: perfect
  #   1: diminished
  #   2: augmented
  CHORD_TONALITIES = [:perfect, :diminished, :augmented]
  

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
  def GuitarProHelper.digit_to_note(digit)
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


  # TODO: Create helper to convert number of increments of .1dB to float for equalizers
  
end