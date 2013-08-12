require 'spec_helper'

describe GuitarProHelper do
  describe '.digit_to_note' do
    it 'converts digit to correct note' do
      digits = [0, 1, 2]
      notes = ['C0', 'C#0', 'D0']
      digits.count.times { |i| (GuitarProHelper.digit_to_note(digits.fetch(i))).should == notes.fetch(i) }
    end
  end

  describe '.note_to_digit' do
    it 'converts note to digit' do
      digits = [0, 1, 2]
      notes = ['C0', 'C#0', 'D0']
      digits.count.times { |i| (GuitarProHelper.note_to_digit(notes.fetch(i))).should == digits.fetch(i) }
    end
  end
end