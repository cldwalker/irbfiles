module RipYard
  def self.config
    { :dependencies=>['public/yard'] }
  end

  # @options :verbose=>:boolean, :rebuild=>:boolean, :yard_options=>:hash
  # Builds yard doc as needed and returns doc path
  def rip_yard(pkg, options={})
    if (pkg_dir = find_package(pkg))
      if options[:yard_options]
        options[:yard_options] = options[:yard_options].map {|k,v|
          dash = k.size > 1 ? "--" : "-"
          [dash + k, v]
        }.flatten
      end
      build_yard_doc(pkg, pkg_dir, options)
    end
  end

  # @options :verbose=>:boolean, :rebuild=>:boolean, :package=>:string, :source=>:boolean,
  #   :doc_packages=>:boolean
  # Builds yard doc as needed and runs yri for current package
  def rip_yri(query, options={})
    if options[:package] && (pkg_dir = find_package(options[:package]))
      build_yard_doc(options[:package], pkg_dir, options.merge(:yard_options=>['-n']))
    end
    dirs = Dir.glob(File.expand_path("~/.rip/.yard/*/.yardoc"))
    dirs = Dir.glob(File.expand_path("~/.rip/.packages/yard-doc-*/.yardoc")) + dirs if options[:doc_packages]
    dirs = dirs.select {|e| e[/#{options[:package]}/] } if options[:package]
    yri query, dirs, options
  end

  private
  def build_yard_doc(pkg, pkg_dir, options)
    yard_dir = File.expand_path("~/.rip/.yard") + "/" + File.basename(pkg_dir)
    require 'fileutils'
    FileUtils.mkdir_p yard_dir
    Dir.chdir yard_dir
    puts "First time building YARD doc for '#{pkg}'..." if !File.exists?('doc')
    if !File.exists?('doc') || options[:rebuild]
      cmd = ['yardoc', '--no-private']
      cmd << '-q' unless options[:verbose]
      cmd += ['-c', '.yardoc']  unless options[:rebuild]
      cmd += options[:yard_options] if options[:yard_options]
      readme = Dir[pkg_dir + '/README*'][0].to_s
      cmd += ['-m', 'markdown'] if readme[/README\.m/]
      cmd += ['-m', 'textile'] if readme[/README\.t/]
      cmd += [pkg_dir + "/lib/**/*.rb", '-', pkg_dir+'/README*']
      puts "Building YARD documentation with: " +cmd.join(' ') if options[:verbose]
      system *cmd
    end
    yard_dir + "/doc/index.html"
  end
end
