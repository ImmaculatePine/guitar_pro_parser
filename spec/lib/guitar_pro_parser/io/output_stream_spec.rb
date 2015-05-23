require 'spec_helper'

TEST_FILE_NAME = 'test_file'

# TODO: Write tests
RSpec.describe GuitarProParser::OutputStream do

  subject { GuitarProParser::OutputStream.new(TEST_FILE_NAME) }
  let(:reader) { GuitarProParser::InputStream.new(TEST_FILE_NAME) }

  describe '#write_integer' do
    it 'writes integer' do
      subject.write_integer(100)
      subject.close
      expect(reader.read_integer).to eq(100)
    end
  end

  describe '#write_signed_integer' do
    it 'writes signed integer' do
      subject.write_signed_integer(-100)
      subject.close
      expect(reader.read_signed_integer).to eq(-100)
    end
  end

  describe '#write_short_integer' do
    it 'writes short integer' do
      subject.write_short_integer(100)
      subject.close
      expect(reader.read_short_integer).to eq(100)
    end
  end

  describe '#write_signed_short_integer' do
    it 'writes signed short integer' do
      subject.write_signed_short_integer(-100)
      subject.close
      expect(reader.read_signed_short_integer).to eq(-100)
    end
  end

  describe '#write_byte' do
    it 'writes byte' do
      subject.write_byte(100)
      subject.close
      expect(reader.read_byte).to eq(100)
    end
  end

  describe '#write_signed_byte' do
    it 'writes signed byte' do
      subject.write_signed_byte(-100)
      subject.close
      expect(reader.read_signed_byte).to eq(-100)
    end
  end

  describe '#write_boolean' do
    it 'writes true' do
      subject.write_boolean(true)
      subject.close
      expect(reader.read_boolean).to eq(true)
    end

    it 'writes false' do
      subject.write_boolean(false)
      subject.close
      expect(reader.read_boolean).to eq(false)
    end
  end

    describe '#write_string' do
    it 'writes string' do
      test_string = 'Test string'
      subject.write_string(test_string)
      subject.close
      expect(reader.read_string(test_string.length)).to eq(test_string)
    end
  end

  describe '#write_chunk' do
    it 'writes chunk' do
      test_string = 'Test string'
      subject.write_chunk(test_string)
      subject.close
      expect(reader.read_chunk).to eq(test_string)
    end
  end

  describe '#write_padding' do
    it 'writes empty bytes' do
      subject.write_padding(4)
      subject.close
      expect(reader.read_integer).to eq(0)
    end
  end

  after(:all) { system("rm #{TEST_FILE_NAME}") }
end