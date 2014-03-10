#!/usr/bin/env ruby
# Convert SASS/SCSS to Stylus
# Initial work by Andrey Popp (https://github.com/andreypopp)

require 'sass'

class ToStylus < Sass::Tree::Visitors::Base

  def self.convert(file)
    options = Sass::Engine::DEFAULT_OPTIONS
    engine = Sass::Engine.for_file(file, options)
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
    emit "@media #{node.query.map{|i| i.is_a?(Sass::Script::Variable) ? i.inspect : i}.join}"
    visit_children node
  end

  def visit_content(node)
    emit '{block}'
  end

  def visit_mixin(node)
    emit "#{node.name}(#{render_args(node.args)})"
  end

  def visit_prop(node)
    emit "#{node.name.join(' ')}: #{node.value.to_sass}"
  end

  def visit_function(node)
    emit "#{node.name}(#{render_args(node.args)})"
    visit_children node
  end

  def visit_rule(node)
    emit node.parsed_rules.to_s
    visit_children node
  end

  def visit_root(node)
    @indent = -1
    @lines = []
    visit_children(node)
    @lines.join("\n")
  end

end
