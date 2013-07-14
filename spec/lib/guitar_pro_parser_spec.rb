require 'spec_helper'

describe GuitarProParser do
  it "should has a version" do
    GuitarProParser::VERSION.should_not be_nil
  end
end