require 'sinatra'

post '/' do
  load 'lib/ruby_converter.rb'
  options = Sass::Engine::DEFAULT_OPTIONS.merge({syntax: :scss})
  engine = Sass::Engine.for_file(params[:file][:tempfile], options)
  tree = engine.to_tree
  stylus = ToStylus.visit(tree)

  stylus_file = Tempfile.new('new_file.stylus')
  stylus_file.write stylus
  stylus_file.rewind
  send_file stylus_file
  stylus_file.close!
end
