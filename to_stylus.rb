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
        if node.value.is_a? Sass::Script::Tree::Operation
          func_output = "#{output}(#{node.value.to_sass})".sub(/(.*)-/, '\1: ').gsub("\#{","{")
        elsif node.value.is_a?(Sass::Script::Tree::UnaryOperation) && node.value.operator.to_s == 'minus'
          func_output = "#{output}".sub(/(.*)-/, '\1: ') <<"-1*#{node.value.operand.inspect}".gsub("\#{","{")
        else
          func_output = "#{output}#{node.value.to_sass}".sub(/(.*)-/, '\1: ').gsub("\#{","{")
        end
        func_support.nil? ? (emit func_output) : (emit "//" << func_output)
      end
      node.children.each do |child|
        visit_prop(child,output)
      end
    else
      unless node.is_a? Sass::Tree::CommentNode
        "#{node.name.join("")[0]}" == "#" ?
          node_name = "#{output}{#{node.name-[""]}}:".tr('[]','') : node_name = "#{output}#{node.name.join('')}:"

        if node.value.is_a? Sass::Script::Tree::Operation
          func_output = node_name << " (#{node.value.to_sass})".gsub("\#{", "{")
        elsif node.value.is_a?(Sass::Script::Tree::UnaryOperation) && node.value.operator.to_s == 'minus'
          func_output = node_name << " -1*#{node.value.operand.inspect}"
        else
          func_output = node_name << " #{node.value.to_sass}".gsub("\#{", "{")
        end
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

  def for_helper(node, from_or_to)
    @@functions['disabled_functions'].each do |func|
      unless (from_or_to).inspect.match(func.to_s).nil?
        @errors.push("//#{func}: line #{node.line} in your Sass file")
        emit "//Function #{func} is not supported in Stylus"
      end
    end
  end

  def visit_for(node)
    (node.from.is_a? Sass::Script::Tree::Funcall) ? for_helper(node, node.from) : nil
    from = node.from.to_sass

    (node.to.is_a? Sass::Script::Tree::Funcall) ? for_helper(node, node.to) : nil
    temp_to = node.to.to_sass

    (node.to.is_a? Sass::Script::Tree::Literal) ? exclusive_to = temp_to.to_i - 1 : exclusive_to = "(#{temp_to}) - 1"
    node.exclusive ? to = exclusive_to : to = temp_to

    emit "for $#{node.var} in (#{from})..(#{to})"
    visit_children node
  end

  def visit_directive(node)
    emit "#{node.name}"
    visit_children node
  end

  def comment_out(node)
    node.to_sass.lines.each {|l| emit "//#{l}".chomp }
  end

  def visit_each(node)
    if node.vars.length == 1
      emit "for $#{node.vars.first} in #{node.list.to_sass}".gsub(",","")
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
