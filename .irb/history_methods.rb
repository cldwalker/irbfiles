require 'tempfile'
## My old stuff for slicing + dicing history
class Array
	def multislice(range,splitter=',',offset=nil)
		result = []
		for r in range.split(splitter)
		if r =~ /-/
			min,max = r.split('-')
			slice_min = min.to_i - 1
			slice_min += offset if offset
			result.push(*self.slice(slice_min, max.to_i - min.to_i + 1))
		else
			index = r.to_i - 1
			index += offset if offset
			result.push(self[index])
		end
		end
		return result
	end
end

$original_history_size = Readline::HISTORY.size
def history_list(first_num,second_num=Readline::HISTORY.size - 1)
	Readline::HISTORY.to_a[(first_num + $original_history_size - 1) .. (second_num + $original_history_size - 1) ]
end
def history_slice(nums)
	Readline::HISTORY.to_a.multislice(nums,',',$original_history_size)
end
def history_list_or_slice(*args)
	if args[0].class == String
		history_slice(*args)
	else
		history_list(*args)
	end
end
def print_history(*args)
	puts history_list_or_slice(*args).join("\n")
end
def eval_history(*args)
	eval %[ #{history_list_or_slice(*args).join("\n")} ]
end
def edit_history(*args)
	history_string = history_list_or_slice(*args).join("\n")
	edit(history_string)
end
def edit(string=nil,editor=ENV['EDITOR'])
	editor ||= raise "editor must be given or defined by EDITOR environment variable"
	tempfile = Tempfile.new('edit')
	File.open(tempfile.path,'w') {|f| f.write(string) } if string
	system("#{editor} #{tempfile.path}")
	File.open(tempfile.path) {|f| f.read } 
end
