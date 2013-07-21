require 'spec_helper'
require 'guitar_pro_parser/guitar_pro_helper'

include GuitarProHelper

describe GuitarProHelper do
  describe '#digit_to_note' do
    it 'converts digit to correct note' do
      digits = [0, 1, 2]
      notes = ['C0', 'C#0', 'D0']
      digits.count.times do |i| 
        (digit_to_note digits[i]).should == notes[i]
      end
    end
  end
end