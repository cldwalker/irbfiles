module Rake
  def self.included(mod)
    require 'rake'
  end

  def rake(task)
    Rake::Task[task.to_s].invoke
  end
end