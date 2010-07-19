module Readme
  # List readme sections
  def sections
    Repo.objects.map {|e| [e.name, e.sections] }
  end

  # @render_options :fields=>[:name, :missing, :extras] 
  # @options :reveal=>:boolean
  # List differences in readme sections
  def section_diff(options={})
    common = %w{Description Bugs/Issues Install}
    optional = options[:reveal] ? [] : %w{Setup Examples Links Motivation Limitations Todo Credits Usage}
    Repo.objects.map {|e|
      {:name=>e.name, :missing=>common - e.sections, :extras=>e.sections - common - optional }
    }
  end

  class Repo
    def self.objects(options={})
      @objects ||= begin
        dirs = Dir[File.expand_path("~/code/gems/*")]
        dirs = menu(dirs) if options[:dirs]
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

    def readme
      @readme ||= File.read(@dir+'/README.rdoc')
    end

    def sections
      @sections ||= readme.scan(/={2,}\s*(.*?)\n/).flatten
    end
  end
end
