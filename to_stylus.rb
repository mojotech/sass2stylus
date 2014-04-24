#!/usr/bin/env ruby
# Convert SASS/SCSS to Stylus
# Initial work by Andrey Popp (https://github.com/andreypopp)

require 'sass'
require 'yaml'

class ToStylus < Sass::Tree::Visitors::Base
  @@functions = YAML::load_file(File.join(__dir__ , 'functions.yml'))

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

  def determine_support(node, is_value)
    is_value ? (node_class = node.value) : (node_class = node.expr)
    if node_class.is_a? Sass::Script::Tree::Funcall
      @@functions['disabled_functions'].each do |func|
        if !node_class.inspect.match(func.to_s).nil?
          @errors.push("//#{func}: line #{node.line} in your Sass file")
          emit "//Function #{func} is not supported in Stylus"
          return func
        end
      end
      return
    end
  end

  def visit_prop(node, output="")
    func_support = determine_support(node, true)
    if !node.children.empty?
      output << "#{node.name.join('')}-"
      unless node.value.to_sass.empty?
        #for nested scss with values, change the last "-" in the output to a ":" to format output correctly
        func_output = "#{output}#{node.value.to_sass}".sub(/(.*)-/, '\1: ').gsub("\#{","{")
        func_support.nil? ? (emit func_output) : (emit "//" << func_output)
      end
      node.children.each do |child|
        visit_prop(child,output)
      end
    else
      unless node.is_a? Sass::Tree::CommentNode
        "#{node.name.join("")[0]}" == "#" ?
          node_name = "#{output}{#{node.name-[""]}}:".tr('[]','') : node_name = "#{output}#{node.name.join('')}:"

        func_output = node_name << " #{node.value.to_sass}".gsub("\#{", "{")
        func_support.nil? ? (emit func_output) : (emit "//" << func_output)
      else
        visit(node)
      end
    end
  end

  def visit_variable(node)
    func_support = determine_support(node, false)
    output = "$#{node.name} = #{node.expr.to_sass}"
    func_support.nil? ? (emit output) : (emit "//" << output)
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
    func_support = determine_support(node, false)
    output = node.expr.to_sass
    func_support.nil? ? (emit output) : (emit "//" << output)
  end

  def visit_comment(node)
    node.invisible? ? lines = node.to_sass.lines : lines = node.value.first.split("\n")
    lines.each { |line| emit line.tr("\n", "")}
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

  def comment_out(node)
    node.to_sass.lines.each {|l| emit "//#{l}".chomp }
  end

  def visit_each(node)
    if node.vars.length == 1
      emit "for $#{node.vars.first} in #{node.list.to_sass}"
      visit_children node
    else
      emit "//Cannot convert multi-variable each loops to Stylus"
      @errors.push("// @each: line #{node.line} in your Sass file")
      comment_out(node)
    end
  end

  def visit_while(node)
    emit "//Stylus does not support while loops"
    @errors.push("// @while: line #{node.line} in your Sass file")
    comment_out(node)
  end

  def visit_atroot(node)
    emit "//Stylus does not support @at-root"
    @errors.push("// @at-root: line #{node.line} in your Sass file")
    comment_out(node)
  end

  def visit_debug(node)
    emit "//Stylus does not support @debug"
    @errors.push("// @debug: line #{node.line} in your Sass file")
    comment_out(node)
  end

  def visit_warn(node)
    emit "//Stylus does not support @warn"
    @errors.push("// @warn: line #{node.line} in your Sass file")
    comment_out(node)
  end

  def visit_root(node)
    @indent = -1
    @errors = []
    @lines = []
    visit_children(node)
    unless @errors.empty?
      @errors.unshift("//Below is a list of the Sass rules that could not be converted to Stylus")
      @errors.push("\n")
      @lines.unshift(*@errors)
    end
    @lines.join("\n")
  end

end
