#!/usr/bin/env ruby
# Convert SASS/SCSS to Stylus
# Initial work by Andrey Popp (https://github.com/andreypopp)

require 'rubygems'
require 'bundler/setup'
require 'sass'

class ToStylus < Sass::Tree::Visitors::Base

  def self.convert(file)
    engine = Sass::Engine.for_file(file, {})

    tree = engine.to_tree
    visit(tree)
  end

  def visit(node)
    if self.class.respond_to? :node_name
      method = "visit_#{node.class.node_name}"
    else
      method = "visit_#{node_name node}"
    end
    if self.respond_to?(method, true)
      self.send(method, node) {visit_children(node)}
    else
      if self.class.respond_to? :node_name
        raise "unhandled node: '#{node.class.node_name}'"
      else
        raise "unhandled node: '#{node_name node}'"
      end
    end
  end

  def visit_children(node)
    @indent += 1
    super(node)
    @indent -= 1
  end

  def visit_prop(node, output="")
    if !node.children.empty?
      output << "#{node.name.join('')}-"
      unless node.value.to_sass.empty?
        emit "#{output}#{node.value.to_sass}".sub(/(.*)-/, '\1: ')
      end
      node.children.each do |child|
        visit_prop(child,output)
      end
    else
      emit "#{output}#{node.name.join('')}: #{node.value.to_sass}"
    end
  end

  def render_arg(arg)
    if arg.is_a? Array
      var = arg[0]
      default = arg[1]
      if default
        "#{arg[0].to_sass} = #{arg[1].to_sass}"
      else
        var.to_sass
      end
    else
      arg.to_sass
    end
  end

  def render_args(args)
    args.map { |a| render_arg(a) }.join(', ')
  end

  def emit(line)
    line = ('  ' * @indent) + line
    @lines.push line
  end

  def visit_if(node, isElse = false)
    line = []
    line.push 'else' if isElse
    line.push "if #{node.expr.to_sass}" if node.expr
    emit line.join(' ')
    visit_children(node)
    visit_if(node.else, true) if node.else
  end

  def visit_return(node)
    emit node.expr.to_sass
  end

  def visit_comment(node)
    node.value.each { |s| emit s }
  end

  def visit_variable(node)
    emit "$#{node.name} = #{node.expr.to_sass}"
  end

  def visit_mixindef(node)
    emit "#{node.name}(#{render_args(node.args)})"
    visit_children node
  end

  def visit_media(node)
    emit "@media #{node.query.map{|i| i.inspect}.join}".gsub! /"/, ""
    visit_children node
  end

  def visit_content(node)
    emit '{block}'
  end

  def visit_mixin(node)
    emit "#{node.name}(#{render_args(node.args)})"
  end

  def visit_import(node)
    emit "@import '#{node.imported_filename}'"
  end

  def visit_cssimport(node)
    if node.to_sass.include?("http://") && !node.to_sass.include?("url")
      emit "@import url(#{node.uri})"
    elsif(node.to_sass.index("\"http") || node.to_sass.index("\'http"))
      emit "#{node.to_sass}".chomp!
    elsif(node.to_sass.index("http"))
      emit "@import #{node.uri}".gsub("(", "(\"").gsub(")", "\")")
    else
      emit "#{node.to_sass}".chomp!
    end
  end

  def visit_extend(node)
    emit "#{node.to_sass}".gsub("%","$").chomp!
  end

  def visit_function(node)
    if node.splat.nil?
      emit "#{node.name}(#{render_args(node.args)})"
    else
      node.args.push([node.splat, nil])
      emit "#{node.name}(#{render_args(node.args)}...)"
    end
    visit_children node
  end

  def visit_rule(node)
    emit "#{node.to_sass.lines[0]}".gsub("\#{", "{").gsub("%", "$").chomp
    visit_children node
  end

  def visit_for(node)
    is_number = Float(node.to.inspect) != nil rescue false
    is_number ? loop_end = node.to.inspect.to_i - 1 : loop_end= "$#{node.to.name} - 1"
    node.exclusive ? to = loop_end : to = node.to.inspect
    emit "for $#{node.var} in (#{node.from.inspect}..#{to})"
    visit_children node
  end

  def visit_each(node)
    if node.vars.length == 1
      emit "for $#{node.vars.first} in #{node.list.to_sass}"
      visit_children node
    else
      emit "//Cannot convert multi-variable each loops to Stylus"
      node.to_sass.lines.each do |l|
        emit "//#{l}".chomp
      end
    end
  end

  def visit_while(node)
    emit "//Stylus does not support while loops"
    node.to_sass.lines.each do |l|
      emit "//#{l}".chomp
    end
  end

  def visit_atroot(node)
    emit "//Stylus does not support @at-root"
    node.to_sass.lines.each do |l|
      emit "//#{l}".chomp
    end
  end

  def visit_debug(node)
    emit "//Stylus does not support @debug"
    node.to_sass.lines.each do |l|
      emit "//#{l}".chomp
    end
  end

  def visit_warn(node)
    emit "//Stylus does not support @warn"
    node.to_sass.lines.each do |l|
      emit "//#{l}".chomp
    end
  end

  def visit_root(node)
    @indent = -1
    @lines = []
    visit_children(node)
    @lines.join("\n")
  end

end
