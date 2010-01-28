# Prints trees of classes and modules.
module Tree
  def self.config
    {:dependencies=>['core/class', 'core/module']}
  end

  OPTIONS = {:class=>:string, :children_method=>:string, :type=>{:type=>:string, :values=>[:directory, :basic, :number]}}
  # @options OPTIONS
  # Prints an inheritance tree given a root class
  def inheritance_tree(klass, options={})
    render klass, {:class=>:parent_child_tree, :children_method=>lambda {|n| class_children(n)},
      :type=>:directory}.merge(options)
  end

  # @options OPTIONS
  # Prints an inheritance tree without Exception classes
  def errorless_inheritance_tree(klass, options={})
    child_lambda = lambda {|n| class_children(n).reject {|e| e < Exception || e.name =~ /Errno/} }
    render klass, {:class=>:parent_child_tree, :children_method=>child_lambda, :type=>:directory}.merge(options)
  end

  # @options OPTIONS
  # Prints a tree of nested classes/modules under a given class/module
  def nested_tree(klass, options={})
    render klass, {:class=>:parent_child_tree, :children_method=>lambda {|e| nested_children(e) },
     :value_method=>lambda {|e| nested_name(e)}, :type=>:directory}.merge(options)
  end

  # @options OPTIONS
  # Displays a nested_tree for the most likely top-level module representing a gem i.e. nokogiri -> Nokogiri
  def gem_tree(rubygem, options={})
    modules = ::Boson::Util.detect(:modules=>true) { require rubygem }[:modules]
    if (klass = ::Boson::Util.constantize(rubygem))
      nested_tree(klass, options)
    elsif (klasses = modules.select {|e| e.to_s[/^[^:]+$/] })
      if (possible_klasses = klasses.select {|e| e.to_s[/^#{rubygem}/i] }).size == 1
        nested_tree(possible_klasses[0], options)
      else
        # Just display the first one we know of
        nested_tree(klasses[0], options)
        puts "Multiple base modules were detected: #{klasses.map {|e| e.to_s }.join(', ')}"
      end
    else
      puts "No base module found for '#{rubygem}'"
    end
  end
end