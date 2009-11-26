#!/usr/bin/ruby
CONF = {'ALL'=>true,'SUB'=>true,'INCLUDE_MODULES'=>0,
	'FILTER'=>{'event'=>1,'class'=>1,'file'=>0,'level'=>0},
	'PRINT_ALL'=>{'event'=>0,'class'=>0,'file'=>1,'line'=>1,'id'=>0,'binding'=>0}
}
#CONF = {%w{EVENT_FILTER 1 PRINT_ALL 0 ONLY_SUB 1}}

 
$indent = 0;
$level = 0;
$modules = %w{Kernel Module IO Fixnum Array Symbol Float Hash String Sub Date Class File Dir Integer Enumerable Regexp}
#$modules = 'IRB::ExtendCommandBundle'
#$modules = %w{Module IO Kernel}
#RI::RiWriter Config RI::MethodEntry RiCache RI::ClassEntry}
#$modules = 'RI'
#$modules = []
$file_filter = 'delegate'
$view = %w{file line }
$HISTORY_SIZE=5
saved_config = []
def print_sub (*args)
	$indent.times {print "\t" }
	printf "#{args[0]}.#{args[1]}" 
end
def print_all (conditions)
	print ": #{conditions.values_at(*$view).join(',')}"
end
condition_aliases = {:event=>:e,:class=>:c,:file=>:f,:line=>:l,:id=>:i,:binding=>:b }
#sub_aliases = {:level_compare,:event_regexp,:class_include,:file_regexp,:class_re}

#test subs: could have multiple ones of these
	def test_level(level)
		level <= $level
	end
	def test_event(event)
		event =~ /call/
	end
	def test_class2(classname)
		classname =~ /#{$modules}/
	end
	def test_class(classname)
		if (CONF['INCLUDE_MODULES'] == 1)
			$modules.include?(classname.to_s) 
		else
			not $modules.include?(classname.to_s)
		end
	end
	def test_file(file)
		file =~ /#{$file_filter}/
	end

def valid_conditions(saved_config)
	#p saved_config
	#values = {'event'=>event,'file'=>file,'class'=>classname,'level'=>$indent}
	bool = true
	CONF['FILTER'].each { |k,v|
		bool = bool && send(:"test_#{k.downcase}",saved_config[-1][k.downcase]) if v ==1
	}
	return bool
end
repeat_count = 0
set_trace_func proc { |event, file, line, id, binding, classname|
	config = {'event'=>event,'file'=>file,'class'=>classname,'id'=>id,'binding'=>binding,'line'=>line}
	saved_config.push(config)
	saved_config.shift if saved_config.length >=$HISTORY_SIZE
	if CONF['SUB'] && CONF['ALL'] 
		if valid_conditions(saved_config)
			#if saved_config[-1][:class] == saved_config[-2][:class] and saved_config[-2][:id] == saved_config[-1][:id]
				#repeat_count +=1 
				#count_on = 1
				##print " #repeat"
			#else
				#repeat_count = 0
			#end

			if repeat_count == 0
				if saved_config[-2]['class'] == false && saved_config[-1]['event'] =~ /call/
					print_sub(classname,id)
					print_all(saved_config[-2]) #if defined? saved_config[-2]
					print " #de"
				else
					print_sub(classname,id)
					print_all(config)
					#print "; "
				end
				print "\n"
			end
		end
	elsif CONF['SUB'] && valid_conditions(saved_config)
		print_sub(classname,id)
		print "\n"
	elsif CONF['ALL']
		print_all(config)
		print "\n"
	end
	#$indent +=1 if saved_config.length > 1 && saved_config[-1]['file'] == saved_config[-2]['file']
	#$indent -=1 if saved_config.length > 1 && saved_config[-1]['file'] != saved_config[-2]['file']
	$indent +=1 if event == "c-call"
	$indent -=1 if event == "c-return"
}

__END__
