require 'spec_helper'

RSpec.describe GuitarProParser::InputStream do
  subject { GuitarProParser::InputStream.new(test_tab_path(5)) }
  
  describe '#read_byte' do
    let!(:result) { subject.read_byte }

    its(:offset) { should == 1}
    specify { expect(result).to eq(24) }
  end

  describe '#read_boolean' do
    let!(:result) { subject.read_boolean }

    its(:offset) { should == 1}
    specify { expect(result).to eq(true) }
  end

  describe '#read_integer' do
    before (:each) do
      subject.offset = 31
    end

    let!(:result) { subject.read_integer }
    
    its(:offset) { should == 35}
    specify { expect(result).to eq(11) }
  end

  describe '#read_short_integer' do
    before (:each) do
      subject.offset = 357
    end

    let!(:result) { subject.read_short_integer }
    
    its(:offset) { should == 359}
    specify { expect(result).to eq(511) }
  end

  shared_examples 'read_string and read_chunk' do
    its(:offset) { should == 46 }
    specify { expect(result).to eq('Song Title') }
  end

  describe '#read_string' do
    before (:each) do
      subject.offset = 36
    end

    let!(:result) { subject.read_string 10 }
  
    it_behaves_like 'read_string and read_chunk'
  end

  describe '#read_bitmask' do
    let!(:result) { subject.read_bitmask }

    its(:offset) { should == 1}
    specify { expect(result).to eq([false, false, false, true, true, false, false, false]) }
  end

  describe '#read_chunk' do
    before (:each) do
      subject.offset = 31
    end

    let!(:result) { subject.read_chunk }
  
    it_behaves_like 'read_string and read_chunk'
  end

  describe '#increment_offset' do
    it 'changes offset' do
      subject.increment_offset 5
      expect(subject.offset).to eq(5)
    end
  end

  describe '#skip_integer' do
    it 'changes offset' do
      subject.skip_integer
      expect(subject.offset).to eq(4)
    end
  end

  describe '#skip_short_integer' do
    it 'changes offset' do
      subject.skip_short_integer
      expect(subject.offset).to eq(2)
    end
  end

  describe '#skip_byte' do
    it 'changes offset' do
      subject.skip_byte
      expect(subject.offset).to eq(1)
    end
  end
end
