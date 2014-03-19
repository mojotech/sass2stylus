$:.unshift(File.join(File.dirname(__FILE__), '..'))
require 'lib/ruby_converter'

describe ToStylus  do
  before do
    @path = File.expand_path('../../fixtures', __FILE__)
  end

  it "converts a sass file to styl" do
    ToStylus.convert("#{@path}/foo.sass").should eq(File.read("#{@path}/foo.styl").chomp)
  end

  it "converts a scss file to styl" do
    ToStylus.convert("#{@path}/foo.scss").should eq(File.read("#{@path}/foo.styl").chomp)
  end
end
