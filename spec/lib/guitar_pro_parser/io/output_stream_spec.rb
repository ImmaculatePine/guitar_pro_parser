require 'spec_helper'

TEST_FILE_NAME = 'test_file'

# TODO: Write tests
describe GuitarProParser::OutputStream do

  subject { GuitarProParser::OutputStream.new(TEST_FILE_NAME) }
  let(:reader) { GuitarProParser::InputStream.new(TEST_FILE_NAME) }

  describe '#write_integer' do
    it 'writes integer' do
      subject.write_integer 100
      subject.close
      reader.read_integer.should == 100
    end
  end

  describe '#write_signed_integer' do
    it 'writes signed integer' do
      subject.write_signed_integer -100
      subject.close
      reader.read_signed_integer.should == -100
    end
  end

  describe '#write_short_integer' do
    it 'writes short integer' do
      subject.write_short_integer 100
      subject.close
      reader.read_short_integer.should == 100
    end
  end

  describe '#write_signed_short_integer' do
    it 'writes signed short integer' do
      subject.write_signed_short_integer -100
      subject.close
      reader.read_signed_short_integer.should == -100
    end
  end

  describe '#write_byte' do
    it 'writes byte' do
      subject.write_byte 100
      subject.close
      reader.read_byte.should == 100
    end
  end

  describe '#write_signed_byte' do
    it 'writes signed byte' do
      subject.write_signed_byte -100
      subject.close
      reader.read_signed_byte.should == -100
    end
  end

  describe '#write_boolean' do
    it 'writes true' do
      subject.write_boolean true
      subject.close
      reader.read_boolean.should == true
    end

    it 'writes false' do
      subject.write_boolean false
      subject.close
      reader.read_boolean.should == false
    end
  end

  describe '#write_chunk' do
    it 'writes chunk' do
      test_string = 'Test string'
      subject.write_chunk(test_string)
      subject.close
      reader.read_chunk.should == test_string
    end
  end

  describe '#write_padding' do
    it 'writes empty bytes' do
      subject.write_padding(4)
      subject.close
      reader.read_integer.should == 0
    end
  end

  after(:all) { system("rm #{TEST_FILE_NAME}") }
end