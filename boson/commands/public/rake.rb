module RakeLib
  def self.included(mod)
    require 'rake'
  end

  # @options :benchmark=>{:type=>:boolean, :desc=>'Benchmarks a task by setting ENV[BENCHMARK]'},
  #   :run=>{:type=>:boolean, :desc=>"Run rake task once by using run() instead of invoke_task()"}
  # Execute a rake task
  def rake(task='default', options={})
    clean_argv
    ENV['BENCHMARK'] = options[:benchmark] ? 'true' : 'false' # to enable test_benchmark gem
    if options[:run]
      ARGV.replace [task]
      Rake.application.run
    else
      unless @rake_tasks_loaded
        Rake.application.init
        Rake.application.load_rakefile
      end
      Rake.application.invoke_task task
    end
  end

  # @render_options :fields=>[:name, :comment]
  # @options :reload=>{:type=>:boolean, :desc=>"Clears existing tasks and reloads current directory tasks"},
  #  :add=>{:type=>:boolean, :desc=>'Adds tasks from current directory'},
  #  :all=>{:type=>:boolean, :desc=>'Lists all tasks including task dependencies'}
  # Lists loaded tasks
  def rake_tasks(options={})
    clean_argv
    if options[:reload] || @rake_tasks_loaded.nil?
      Rake.application.clear
      Rake.application.init
      Rake.application.load_rakefile
      @rake_tasks_loaded = true
    elsif options[:add]
      Rake.application.load_rakefile
    end
    options[:all] ? Rake.application.tasks : Rake.application.tasks.select {|e| e.comment}
  end

  private
  def clean_argv
    ARGV.delete_if {|e| e[/^-/] } unless ARGV.empty?
  end
end