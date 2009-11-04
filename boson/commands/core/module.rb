module ModuleLib
  # Children modules immediately under a module.
  def nested_children(mod)
    real_constants(mod).map {|e| mod.const_get(e) }.select {|e| e.is_a?(Module) } - [mod]
  end

  # Last part of a module name i.e. Boson::Commands::Ansi -> Ansi
  def nested_name(mod)
    mod.to_s.split("::")[-1]
  end

  # Returns constants that are only defined in module and not in a module's ancestors.
  def real_constants(mod)
    mod.constants.select {|e| mod.const_defined?(e)}
  end
end
