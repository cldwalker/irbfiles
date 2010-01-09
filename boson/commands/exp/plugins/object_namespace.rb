# Plugin that delegates namespace calls to an object defined by a method whose name is the same
# as its library.
class ::Boson::Namespace
  class<<self
    alias_method :_create, :create

    def create(name, library)
      if library.object_namespace && library.module.instance_methods.map {|e| e.to_s}.include?(name)
        library.include_in_universe
        create_object_namespace(name, library)
      else
        _create(name, library)
      end
    end

    def create_object_namespace(name, library)
      obj = library.namespace_object
      obj.instance_eval("class<<self;self;end").send(:define_method, :boson_commands) {
        self.class.instance_methods(false) }
      obj.instance_eval("class<<self;self;end").send(:define_method, :object_delegate?) { true }
      namespaces[name.to_s] = obj
    end
  end

  def object_delegate?; false; end
end