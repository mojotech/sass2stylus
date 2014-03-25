$:.unshift(File.join(File.dirname(__FILE__), '..'))
require 'to_stylus'

describe ToStylus  do
  before do
    @path = File.dirname(__FILE__)
  end

  it "converts a sass file to styl" do
    ToStylus.convert("#{@path}/fixtures/foo.sass").should eq(File.read("#{@path}/fixtures/foo.styl").chomp)
  end

  it "converts a scss file to styl" do
    ToStylus.convert("#{@path}/fixtures/foo.scss").should eq(File.read("#{@path}/fixtures/foo.styl").chomp)
  end

  it "handles scss extends" do
    ToStylus.convert("#{@path}/fixtures/extend.scss").should eq(File.read("#{@path}/fixtures/extend.styl").chomp)
  end

  it "handles sass extends" do
    ToStylus.convert("#{@path}/fixtures/extend.sass").should eq(File.read("#{@path}/fixtures/extend.styl").chomp)
  end

end
