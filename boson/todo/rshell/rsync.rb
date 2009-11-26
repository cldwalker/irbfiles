require 'commands/irb/aliases'

class SysAdmin
	class <<self
		#Rsync
		def smart_rsync(*args)
			#should have matching entries in dir_aliases

			if args[0].is_a?(Symbol) && new_source = unalias_dir(args[0])
				if new_dest = fetch_dest_alias(args[0])
					new_args = [new_source, new_dest] 
					new_args += args[1..-1] if args[1..-1]
				else
					new_args = [new_source] + args[1..-1]
				end
				multi_rsync(*new_args)
			else
				rsync(*args)
			end
		end

		def fetch_dest_alias(dir,options={})
			options = {:mac_root=>'/mnt/mac/baby', :win_root=>'/mnt/win', :backup_root=>'/Volumes/MISKI'}.update(options)
			mac_root = options[:mac_root]
			win_root = options[:win_root]
			backup_root = options[:backup_root]
			dest_aliases = {
				:core=>"#{backup_root}/core/",
				:home=>"#{mac_root}/bozo/",
				:dot=>"#{mac_root}/bozo/",
				:rare=>"#{mac_root}/bozo/",
				:ref=>"#{mac_root}/bozo/misc/",
				:m=>"#{win_root}/share/songs/",
				:etc=>"#{mac_root}/"
			}
			dest_aliases[dir]
		end

		def multi_rsync(*args)
			if args[0].is_a?(Array)
				options = (args[-1].is_a?(Hash) ) ? args[-1] : {}
			        source_files = args.shift
				source_files.each {|e|
					new_args = [e] + args
					rsync(*new_args)
					break if ! options[:measure] && ask_yes_no("Exit (y/N)?")
				}
			else
				rsync(*args)
			end
		end

		def rsync(*args)
			options = (args[-1].is_a?(Hash) ) ? args.pop : {}
			cmd = "rsync "
			default_options = { :mac=>'--exclude .DS_Store -t --modify-window 1',
				:default=>'-rv --exclude .svn', :extra=>'', :file_extra=>'',
				:measure=>false, :prefix=>'', :confirm=>true
			}
			arg_options = {
				'/home/bozo/Music'=>'--exclude rip',
				'/home/bozo/Pictures'=>'--exclude pics',
				#'/home/bozo/docs'=>'--exclude cap',
				'/home/bozo/misc/ref'=>'--exclude html --exclude examples --exclude code',
				'/mnt/m'=>'--exclude try'
			}
			default_options[:file_extra] = arg_options[args[0]] if arg_options[args[0]]

			#options
			options = default_options.alias_update(options)
			cmd = options[:prefix] + ' ' + cmd if options[:prefix]
			rsync_options = [:default, :mac, :extra, :file_extra].map {|e| options[e]}.join(' ')

			cmd += rsync_options + ' ' + args.join(' ')

			if options[:measure]
				puts cmd
				output = `#{cmd}`
				determine_rsync_complete(output)

			elsif ! options[:confirm] || ask_yes_no("#{cmd}\nProceed (y/N)?")
				#system cmd
				smart_system(cmd,:return=>:pager)
			else
				cmd
			end
		end

		def determine_rsync_complete(text)
			text =~ /received (\d+) bytes/
			#rsync complete if <= 20 received bytes
			puts "received #{$1} bytes"
			($1.to_i <= 20) ? true : false
		end

		#auto_rsync: get status back from directories, save options/status by dir
		#later: add --delete, file size checking
	end
end
