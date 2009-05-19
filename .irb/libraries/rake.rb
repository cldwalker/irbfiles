module Rake
  def self.init
    require 'rake'
  end

  def rake(task)
    Rake::Task[task.to_s].invoke
  end
end