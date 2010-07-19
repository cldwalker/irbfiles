# Manage gem-building files across projects
module Paz
  def self.config
    {:namespace=>'z'}
  end

  def self.included(mod)
    require 'fileutils'
  end

  # @options :verbose=>:boolean, :noop=>:boolean
  # Update current project
  def push(dir='.', options={})
    FileUtils.cp_r Paz.template_dir+'/.', dir , options
    FileUtils.cp(Paz.gemspec, dir, options) unless File.exists? dir+'/.gemspec'
  end

  # @options :verbose=>:boolean, :noop=>:boolean,
  #  :menu=>:boolean
  # Update across multiple projects
  def update(options={})
    projects = options.delete(:menu) ? menu(Paz.projects) : Paz.projects
    projects.each {|e| push(e, options) }
  end

  # @options :all=>:boolean, :pretend=>:boolean
  # Adds extra line to gemspecs
  def add_to_gemspec(*args)
    options = args[-1].is_a?(Hash) ? args.pop : {}
    project_gemspecs(options).each {|e|
      body = File.read(e)
      new_body = body.sub /(\nend\n?)/, "\n  #{args.join(' ')}\\1"
      options[:pretend] ? puts(new_body) : File.open(e, 'w') {|f| f.write new_body }
    }
    nil
  end

  # @options :all=>:boolean, :pretend=>:boolean, :replace=>{:type=>:string, :bool_default=>true}
  # Updates a particular gemspec attribute's value
  def edit_gemspec(sattr, new_text, options={})
    project_gemspecs(options).each {|e|
      body = File.read(e)
      new_body = options[:replace] == true ? body.sub(/(s\.#{sattr}\s*=?\s*).*?\n/, "\\1#{new_text}\n") :
        body.sub(/(s\.#{sattr}.*?)#{options[:replace]}/, "\\1#{new_text}")
      options[:pretend] ? puts(new_body) : File.open(e, 'w') {|f| f.write new_body }
    }
    nil
  end

  # @options :all=>:boolean
  # Diff templates against current project
  def diff(options={})
    projects = options[:all] ? Paz.projects : ['.']
    projects.each do |e|
      system "diff -r #{e} #{Paz.template_dir} |grep -v '^Only in'"
    end
    nil
  end

  # @options :all=>:boolean, :reveal=>:boolean
  # Displays project(s) gemspec attribute names that differ from standard
  def attribute_diff(options={})
    project_gemspecs(options).inject([]) {|a,e|
      local = Paz.gemspec_attributes e
      a << {:extras=>Paz.extra_attributes(local, options[:reveal]),
        :missing=>Paz.standard_attributes - local, :name=>File.dirname(e) }
    }
  end

  # @options :attributes=>%w{files}, :all=>:boolean, :reveal=>:boolean
  # Display project(s) gemspec attribute values that differ from standard
  def gemspec_diff(options={})
    attribute_regex = options[:attributes].map {|e| "s\\.#{e}" }.join('\|')
    project_gemspecs(options).inject([]) {|a,e|
      cmd = "diff #{e} #{Paz.gemspec}"
      cmd << " |grep '#{attribute_regex}'" unless options[:reveal]
      if !(output = `#{cmd}`).empty?
        puts cmd, output, ""
      end
    }
  end

  private
  def project_gemspecs(options)
    (options[:all] ? Paz.projects : ['.']).map {|e| e+'/.gemspec' }
  end

  class <<self
    def gemspec_attributes(file)
      #gemspec_hash(file).keys.uniq
      IO.readlines(file).map {|e| e[/^\s*s\.(\w+)/, 1] }.compact.uniq
    end

    # use later
    def gemspec_hash(file)
      IO.readlines(file).inject({}) {|t,e|
        if name = e[/^\s*s\.(\w+)\s*=?\s*(.*)$/, 1]
          t[name] = $2
        end
        t
      }
    end

    def extra_attributes(attrs, reveal=false)
      hidden = reveal ? [] : %w{add_dependency add_development_dependency executables extras} 
      attrs - (hidden + standard_attributes)
    end

    def standard_attributes
      @standard_attributes ||= gemspec_attributes(gemspec)
    end

    def gemspec
      File.expand_path "~/.paz/.gemspec"
    end

    def projects
      Dir.glob(File.expand_path("~/code/gems/*"))
    end

    def template_dir
      @template_dir ||= File.expand_path("~/.paz/template")
    end
  end
end
