module Readme
  # List readme sections
  def sections
    Repo.objects.map {|e| [e.name, e.sections] }
  end

  # @render_options :fields=>[:name, :missing, :extras] 
  # @options :reveal=>:boolean, :menu=>:boolean
  # List differences in readme sections
  def section_diff(options={})
    common = %w{Description Bugs/Issues Install}
    optional = options[:reveal] ? [] : %w{Setup Examples Links Motivation Limitations Todo Credits Usage}
    Repo.objects(options).map {|e|
      {:name=>e.name, :missing=>common - e.sections, :extras=>e.sections - common - optional }
    }
  end

  # Fetches readme's description from current project
  def readme_description
    Repo.new('.').description.gsub(/\{([^}]+)\}\[([^\]]+)\]/, '\1')
  end

  class Repo
    def self.objects(options={})
      @objects ||= begin
        dirs = Dir[File.expand_path("~/code/gems/*")]
        dirs = Boson.invoke(:menu, dirs) if options[:menu]
        dirs.map {|e| new(e) }
      end
    end

    attr_reader :dir
    def initialize(dir)
      @dir = dir
    end

    def name
      File.basename @dir
    end

    def section_value(section)
      readme[/==*\s*#{section}(.*?)==/m, 1]
    end

    def description
      section_value('Description').gsub("\n", ' ').strip
    end

    def readme
      @readme ||= File.read(@dir+'/README.rdoc')
    end

    def sections
      @sections ||= readme.scan(/==*\s*(.*?)\n/).flatten
    end
  end
end
