class ::Boson::Command
  class<<self
    alias_method :_newer_options, :new_options
    def new_options(name, library)
      opt = _newer_options(name, library)
      opt.merge!(:render_options=>{:command=>{:default=>'browser'}, :render=>true}) if library.name.include?('url/')
      opt
    end
  end
end

# All libraries under a url/ directory default to having their commands' string outputs passed to browser() to
# be opened in a browser.
module UrlLibraries
end
