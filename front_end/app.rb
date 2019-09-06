require 'sinatra'
require "haml"

get '/' do
  haml :index
end

post '/ajax' do
  load File.expand_path('to_stylus.rb', settings.root)
  options = {syntax: params[:sass_textarea].include?(";") ? :scss : :sass}
  engine = Sass::Engine.new( params[:sass_textarea], options )
  begin
    tree = engine.to_tree
    stylus = ToStylus.visit(tree)
  rescue => e
  end
  e.nil? ? stylus : "Error: #{e.message} \nLine: #{e.sass_line}"
end

post '/download' do
  stylus_file = Tempfile.new("")
  stylus_file.write params[:stylus_textarea]
  stylus_file.rewind
  send_file(stylus_file, :filename => "new_file.styl")
  stylus_file.close!
end

post '/api' do
  load File.expand_path('to_stylus.rb', settings.root)
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
