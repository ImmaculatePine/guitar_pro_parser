require 'spec_helper'

RSpec.describe GuitarProHelper do
  describe '.digit_to_note' do
    it 'converts digit to correct note' do
      expect(GuitarProHelper.digit_to_note(0)).to eq('C0')
      expect(GuitarProHelper.digit_to_note(1)).to eq('C#0')
      expect(GuitarProHelper.digit_to_note(2)).to eq('D0')
    end
  end

  describe '.note_to_digit' do
    it 'converts note to digit' do
      expect(GuitarProHelper.note_to_digit('C0')).to eq(0)
      expect(GuitarProHelper.note_to_digit('C#0')).to eq(1)
      expect(GuitarProHelper.note_to_digit('D0')).to eq(2)
    end
  end
end