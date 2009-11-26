require "g/hash"
require "g/dir"

GEMDIR = '/opt/local/lib/ruby/gems/1.8/gems'
GEMDOCDIR = '/opt/local/lib/ruby/gems/1.8/doc'
#RIDIR= '/usr/local/share/ri/1.8/'
RIDIR= '/opt/local/share/ri/'
RAILS_GEMS = %w{activesupport activerecord actionmailer actionpack rails actionwebservice}

class RIManager
class <<self

	def gem_versions_hash
		gem_versions = {}
		gem_list.each {|e|
			if e =~ /^(\S+)-([\d.]+)$/
				gem_versions[$1] ||= []
				gem_versions[$1] << $2
			else
				puts "invalid gem-version '#{e}'"
			end
		}
		gem_versions
	end

	def gem_cd(gem=nil)
		gem_name = choose_gem(gem, GEMDIR)
		directory = File.join(GEMDIR,gem_name)
		SysAdmin.open_dir(directory)
	end

	def choose_gem(gem, dir)
		doc_gems = Dir.simple_entries(dir)
		gem_dirs = (gem) ? doc_gems.grep(/#{gem}/i) : doc_gems
		smart_menu(gem_dirs, :choose=>:one)
	end

	def open_gem_doc(gem=nil)
		gem_name = choose_gem(gem,GEMDOCDIR)
		html_file = File.join(GEMDOCDIR, gem_name, 'rdoc','index.html')
		puts "Checking for #{html_file}"
		if File.exists?(html_file)
			system("open #{html_file}")
		else
			make_gem_rdoc(gem_name)
			system("open #{html_file}") if File.exists?(html_file)
		end
	end

	def make_gem_rdoc(gem_name)
		#`gem rdoc gem_name`
		output_dir = File.join(GEMDOCDIR,gem_name,'rdoc')
		cmd = "rdoc -o #{output_dir} #{File.join(GEMDIR, gem_name, 'lib')} #{File.join(GEMDIR,gem_name, 'README')}"
		system(cmd)
	end

	def gem_list
		Dir.simple_entries(GEMDIR)
	end

	def latest_gems(gem_versions=gem_versions_hash)
		gem_versions.map {|g,v|
			g + "-" + v.sort[-1]	
		}
	end

	def update_gems_ri
		ri_dir = RIDIR + 'gems'
		#Dir.unlink(ri_dir)
		gem_versions = gem_versions_hash
		rails_gems = gem_versions.delete_keys!(RAILS_GEMS)
		command = "sudo rdoc -r -o #{ri_dir} #{latest_gems(gem_versions).map {|e| File.join(GEMDIR,e,'lib') }.select {|e| File.exists?(e) }.join(' ') }"
		p command
		system command
	end

	def update_rails_ri
		ri_dir = RIDIR + 'rails'
		#Dir.unlink(ri_dir)
		gem_versions = gem_versions_hash
		rails_gems = gem_versions.delete_keys!(RAILS_GEMS)
		command = "sudo rdoc -r -x lib/rails_generator/generators/components/controller/templates/controller.rb -o #{ri_dir} #{latest_gems(rails_gems).map {|e| File.join(GEMDIR,e,'lib') }.join(' ') }"
		p command
		system command
	end
end
end
