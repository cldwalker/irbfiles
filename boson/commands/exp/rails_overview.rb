# Doesn't currently work because it's loading an incorrect version of rdoc
module Overview
  # This was useful back in the day when Rails projects were small and I wanted to a quick overview of
  # the project. Can be run from the root directory of a rails project or with a specified rails directory.
  # By default this script only looks in the models, controllers and helpers directories for ruby classes 
  # but that can be configured.
  #
  # option :nosort, "Displays original order of methods for each class"
  # option :delete_empty, "Deletes classes that don't have any methods"
  # @options :nosort=>:boolean, :delete_empty=>:boolean, :rails_root=>:string
  # Prints out a tree of classes and their methods for a rails project. 
  def overview(directories = %w{models helpers controllers}, options={})
  	rails_root = options[:rails_root] || (File.exists?(File.join(Dir.pwd,'config','environment.rb')) ?
  	  Dir.pwd :	raise("No rails root detected. Add a default rails root."))
    setup_rdoc_parser

    dir_info = {}
    directories.each { |e|
    	full_dir = File.join(rails_root,'app',e)
    	unless File.exists?(full_dir)
    		puts "nonexistant directory '#{full_dir}' skipped"
    		next
    	end
    	files = Dir.glob(full_dir +"/**/*")
    	dir_info[e] = files.grep(/\.rb$/).map {|f| parse_methods_from_file(f) }.inject({}) {|t,s| t.update(s) }

    	if options[:delete_empty] 
    		dir_info[e].each { |k,s|
    			dir_info[e].delete(k) if dir_info[e][k].empty?
    		}
    	end
    	unless options[:nosort]
    		dir_info[e].each { |k,sub|
    			dir_info[e][k] = sub.sort
    		}
    	end
    }
    #could also use yaml_format()
    puts "\n",outline_format(dir_info)
  end

  private
  def setup_rdoc_parser
    #Known to work with rdoc for ruby 1.8.2, 1.8.4 and 1.8.6
    require 'rdoc/rdoc.rb'
    #to avoid issues in rdoc/parsers/parse_rb.rb
    ::Options.instance.instance_eval "@tab_width = 8"
  end

  def index_class(cls,hash)
  	class_name = cls.full_name
  	hash[class_name] = cls.method_list.map {|x| x.name } if ! hash[class_name]
  	#indexes subclasses of a class
  	cls.each_classmodule { |x| index_class(x,hash) }
  end

  # Correctly parses methods with explicit classes. 
  # Todo: Doesn't correctly parse global methods ie methods without a class.
  def rdoc_parse_file(file)
  	class_hash = {}
  	content = File.open(file, "r") {|f| f.read}
  	capital_p = RDoc::ParserFactory.parser_for(RDoc::TopLevel.new(file),file,content,::Options.instance,RDoc::Stats.new)
  	capital_p.scan
  	rclasses = RDoc::TopLevel.all_classes_and_modules
  	rclasses.each {|rc| index_class(rc,class_hash) }
  	RDoc::TopLevel::reset
  	class_hash
  end

  # Returns hash of class to methods pairs
  def parse_methods_from_file(filename)
  	#other parsers could be used here
  	rdoc_parse_file(filename)
  end

  def yaml_format(dir_info)
  	dir_info.to_yaml + "\n"	
  end

  def outline_format(dir_info)
  	body = ''
  	indent = "\t"
  	dir_info.each {|dir,info|
  		body += dir + "\n"
  		body += info.to_yaml.gsub!("\n","\n#{indent}").sub!(/^-+.*?\n/,'') + "\n"
  	}
  	body
  end
end