require 'sinatra'

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end

post '/ajax' do
  load 'converter.rb'
  options = Sass::Engine::DEFAULT_OPTIONS.merge({syntax: :scss})
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
