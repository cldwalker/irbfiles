require 'rake'
load 'Rakefile' if File.exists?('Rakefile')
def rake(task)
  Rake::Task[task.to_s].invoke
end
