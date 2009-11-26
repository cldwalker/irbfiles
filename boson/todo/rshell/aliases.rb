class SysAdmin
	class <<self
		def unalias_dir(dir)
			#dirs which should be bunched into a string ie rsync all at once
			dirs_to_flatten = [:core]
			aliased = fetch_alias(dir) || dir
			return nil unless aliased.respond_to?(:map)

			unaliased = aliased.map {|e|
				(e.is_a?(Symbol)) ? unalias_dir(e) : e
			}.flatten.compact

			dirs_to_flatten.include?(dir) ? unaliased.join(' ') : unaliased
		end

		def unalias_dirs(args,options={})
			new_args = args.map {|e|
				e.is_a?(String) ? e : fetch_alias(e)
			}.compact.flatten.uniq
			(options[:return] == :string) ? new_args.join(' ') : new_args
		end

		def reset_dir_aliases(value=nil)
			@dir_aliases = value || $config[:dir_aliases]
		end

		protected
		def fetch_alias(dir)
			if @dir_aliases.nil?
				@dir_aliases = $config[:dir_aliases]
				dynamic_hash = {:dot=>get_dot_files.join(' ')}
				#:code=>Files.find_by_assoc_name($tag[:sy_code]).map {|e| e.fullname.to_short_dirfile! }.join(' '),
				@dir_aliases.update(dynamic_hash)
			end

			return @dir_aliases[dir]
		end
		def get_dot_files
			exceptions = ['.Trash', '.limewire', '.mldonkey', '.', '..'].map {|e| "/home/bozo/#{e}" }
			arr = Dir.glob("/home/bozo/.*")
			arr -= exceptions
			arr
		end
	end
end

__END_

# from my_main.rb
	:dir_aliases=> {
		:code=>['/home/bozo/.my_rails', '/home/bozo/.irb', '/home/bozo/.rshell', '/home/bozo/bin/ruby/g', '/home/bozo/.irb.rb', '/home/bozo/.irb_rails.rb'],
		:code2=>['/home/bozo/bin', '/home/bozo/proj/gems'],
		:ruby=>['/sw/lib/ruby/1.8'],
		:gems=>['/sw/lib/ruby/gems/1.8/gems'],
		:test=>'/home/bozo/bin/ruby/test',
		:shellable=>['/home/bozo/.my_rails/shellable', '/home/bozo/proj/gems/shellable'],
		:core=>[:code,:test,:core_docs, :code2],
		:core_docs=>['/home/bozo/docs/notes','/home/bozo/docs/comp'],

		##source rsync aliases: need to having matching dest alias
		#always changing: Desktop, temp
		:home=>['/home/bozo/Documents', '/home/bozo/Library', '/home/bozo/Music', '/home/bozo/Pictures',
		  '/home/bozo/apps', '/home/bozo/bin', '/home/bozo/docs'],
		:rare=>'/home/bozo/Mail /home/bozo/Movies /home/bozo/Public /home/bozo/Sites',
		:ref=>'/home/bozo/misc/ref',
		:m=>'/mnt/m',
		:etc=>'/private/etc',
		#:proj, gems, rails_shell, scripts, rr?, tagit
		#wierd sizes: Library, docs/cap, proj/gems, ref/comp/html,ref/comp/examples, ruby
		#:proj, :ruby, :db
	},
