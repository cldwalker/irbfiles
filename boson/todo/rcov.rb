require 'thor/tasks'

class Test < Thor
  desc "rcov", "rcov"
  def rcov
    default_options = {:verbose=>true, :rcov=>"-T -x '/Library/Ruby/*'" }
    file_list = Dir['test/**/*_test.rb']
    create_rcov_cmd(file_list, default_options)
  end

  def create_rcov_cmd(file_list, opts = {})
    #name = opts.delete(:name) || "spec"
    rcov_dir = opts.delete(:rcov_dir) || "coverage"
    file_list = file_list.map {|f| %["#{f}"]}.join(" ")
    verbose = opts.delete(:verbose)
    #opts = {:format => "specdoc", :color => true}.merge(opts)

    #rcov_opts = ::Thor.convert_task_options(opts.delete(:rcov) || {})
    rcov_opts = opts.delete(:rcov) || ''
    rcov = !rcov_opts.empty?
    options = ::Thor.convert_task_options(opts)

    if rcov
      FileUtils.rm_rf(File.join(Dir.pwd, rcov_dir))
    end

    cmd = "ruby "
    if rcov
      cmd << "-S rcov -o #{rcov_dir} #{rcov_opts} "
    end
    cmd << `which spec`.chomp
    cmd << " -- " if rcov
    cmd << " "
    cmd << file_list
    cmd << " "
    cmd << options
    puts cmd if verbose
    system(cmd)
    exit($?.exitstatus)
  end

end
