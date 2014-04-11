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

  it "handles scss media queries" do
    ToStylus.convert("#{@path}/fixtures/media_queries.scss").should eq(File.read("#{@path}/fixtures/media_queries.styl").chomp)
  end

  it "handles sass media queries" do
    ToStylus.convert("#{@path}/fixtures/media_queries.sass").should eq(File.read("#{@path}/fixtures/media_queries.styl").chomp)
  end

  it "handles scss import" do
    ToStylus.convert("#{@path}/fixtures/import.scss").should eq(File.read("#{@path}/fixtures/import.styl").chomp)
  end

  it "handles sass import" do
    ToStylus.convert("#{@path}/fixtures/import.sass").should eq(File.read("#{@path}/fixtures/import.styl").chomp)
  end

  it "handles scss argument splats" do
    ToStylus.convert("#{@path}/fixtures/argument_splat.scss").should eq(File.read("#{@path}/fixtures/argument_splat.styl").chomp)
  end

  it "handles sass argument splats" do
    ToStylus.convert("#{@path}/fixtures/argument_splat.sass").should eq(File.read("#{@path}/fixtures/argument_splat.styl").chomp)
  end

  it "converts scss content to {block}" do
    ToStylus.convert("#{@path}/fixtures/content.scss").should eq(File.read("#{@path}/fixtures/content.styl").chomp)
  end

  it "converts sass content to {block}" do
    ToStylus.convert("#{@path}/fixtures/content.sass").should eq(File.read("#{@path}/fixtures/content.styl").chomp)
  end

  it "handles sass for loops" do
     ToStylus.convert("#{@path}/fixtures/for.sass").should eq(File.read("#{@path}/fixtures/for.styl").chomp)
  end

  it "handles scss for loops" do
    ToStylus.convert("#{@path}/fixtures/for.scss").should eq(File.read("#{@path}/fixtures/for.styl").chomp)
  end

  it "handles sass interpolation" do
     ToStylus.convert("#{@path}/fixtures/interpolation.sass").should eq(File.read("#{@path}/fixtures/interpolation.styl").chomp)
  end

  it "handles scss interpolation" do
    ToStylus.convert("#{@path}/fixtures/interpolation.scss").should eq(File.read("#{@path}/fixtures/interpolation.styl").chomp)
  end

  it "converts sass each iteration to for loop" do
     ToStylus.convert("#{@path}/fixtures/each.sass").should eq(File.read("#{@path}/fixtures/each.styl").chomp)
  end

  it "converts scss each iteration to for loop" do
    ToStylus.convert("#{@path}/fixtures/each.scss").should eq(File.read("#{@path}/fixtures/each.styl").chomp)
  end

  it "comments out sass while loops" do
     ToStylus.convert("#{@path}/fixtures/while.sass").should eq(File.read("#{@path}/fixtures/while.styl").chomp)
  end

  it "comments out scss while loops" do
    ToStylus.convert("#{@path}/fixtures/while.scss").should eq(File.read("#{@path}/fixtures/while.styl").chomp)
  end

  it "comments out sass @at-root" do
     ToStylus.convert("#{@path}/fixtures/atroot.sass").should eq(File.read("#{@path}/fixtures/atroot.styl").chomp)
  end

  it "comments out scss @at-root" do
    ToStylus.convert("#{@path}/fixtures/atroot.scss").should eq(File.read("#{@path}/fixtures/atroot.styl").chomp)
  end

  it "comments out sass @debug" do
     ToStylus.convert("#{@path}/fixtures/debug.sass").should eq(File.read("#{@path}/fixtures/debug.styl").chomp)
  end

  it "comments out scss @debug" do
    ToStylus.convert("#{@path}/fixtures/debug.scss").should eq(File.read("#{@path}/fixtures/debug.styl").chomp)
  end

  it "comments out sass @warn" do
     ToStylus.convert("#{@path}/fixtures/warn.sass").should eq(File.read("#{@path}/fixtures/warn.styl").chomp)
  end

  it "comments out scss @warn" do
    ToStylus.convert("#{@path}/fixtures/warn.scss").should eq(File.read("#{@path}/fixtures/warn.styl").chomp)
  end

  it "handles sass placeholder selectors" do
     ToStylus.convert("#{@path}/fixtures/placeholder_selectors.sass").should eq(File.read("#{@path}/fixtures/placeholder_selectors.styl").chomp)
  end

  it "comments scss placeholder selectors" do
    ToStylus.convert("#{@path}/fixtures/placeholder_selectors.scss").should eq(File.read("#{@path}/fixtures/placeholder_selectors.styl").chomp)
  end

  it "handles sass nested properties" do
     ToStylus.convert("#{@path}/fixtures/nested_properties.sass").should eq(File.read("#{@path}/fixtures/nested_properties.styl").chomp)
  end

  it "comments scss nested properties" do
    ToStylus.convert("#{@path}/fixtures/nested_properties.scss").should eq(File.read("#{@path}/fixtures/nested_properties.styl").chomp)
  end
end
