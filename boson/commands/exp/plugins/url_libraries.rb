# All libraries under a url/ directory default to having their commands' string outputs passed to browser() to
# be opened in a browser.
class ::Boson::Command
  class<<self
    alias_method :_newer_attributes, :new_attributes
    def new_attributes(name, library)
      opt = _newer_attributes(name, library)
      opt.merge!(:render_options=>{:pipes=>{:default=>['browser']}, :render=>true}) if library.name.include?('url/')
      opt
    end
  end
end