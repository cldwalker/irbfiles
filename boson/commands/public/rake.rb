module RakeLib
  def self.included(mod)
    require 'rake'
  end

  # @options :benchmark=>:boolean
  # Run rake tasks in current directory. Defaults to test task regardless of rake default
  def rake(task=nil, options={})
    ARGV.replace(task ? [task] : ['test'])
    case ARGV[0]
    when 'test'
      ENV['BENCHMARK'] = options[:benchmark] ? 'true' : 'false'
    end
    Rake.application.run
  end

  # Another way of invoking a task
  def rake_task(task)
    Rake.application.init
    Rake.application.load_rakefile
    Rake.application.invoke_task(task)
  end

  # Tasks in current directory
  def rake_tasks
    Rake.application.init
    Rake.application.load_rakefile
    Rake.application.tasks
  end
end