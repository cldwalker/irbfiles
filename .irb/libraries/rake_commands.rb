require 'rake'

module RakeCommands
  def rake(task)
    Rake::Task[task.to_s].invoke
  end
end