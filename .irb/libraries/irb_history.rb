# Similar to utility_belt's command history
# Prints, evals and edits history by specifying start and end history numbers.
# For example, 1-3,7 specifies lines 1 through 3 and line 7. Default is all lines.
# Note: This library needs to be used at startup until I find a call to indicate that IRB is initialized.
module IrbHistory
  class<<self; attr_accessor :original_history_size ; end
  
  def self.init
    require 'tempfile'
    IRB_PROCS[:set_command_history] = lambda { self.original_history_size =  Readline::HISTORY.size }
  end
  
  def print_history(*args)
    # puts history_list_or_slice(*args).join("\n")
    history_list_or_slice(*args).compact.each_with_index {|e,i| puts "#{i+1}: #{e}"}
    nil
  end

  def eval_history(*args)
    eval %[ #{history_list_or_slice(*args).join("\n")} ]
  end

  def edit_history(*args)
    history_string = history_list_or_slice(*args).join("\n")
    edit(history_string)
  end

  private
  def edit(string=nil,editor=ENV['EDITOR'])
    editor ||= raise "editor must be given or defined by EDITOR environment variable"
    tempfile = Tempfile.new('edit')
    File.open(tempfile.path,'w') {|f| f.write(string) } if string
    system("#{editor} #{tempfile.path}")
    File.open(tempfile.path) {|f| f.read } 
  end

  def history_list(start_num=1,end_num=Readline::HISTORY.size - 1)
    Readline::HISTORY.to_a[(start_num + original_history_size - 1) .. (end_num + original_history_size - 1) ]
  end

  def history_slice(nums)
    multislice(Readline::HISTORY.to_a, nums,',', original_history_size)
  end

  def original_history_size
    Iam::Libraries::HistoryCommands.original_history_size
  end

  def history_list_or_slice(*args)
    if args[0].class == String
      history_slice(*args)
    else
      history_list(*args)
    end
  end

  def multislice(array, range,splitter=',',offset=nil)
    result = []
    for r in range.split(splitter)
    if r =~ /-/
      min,max = r.split('-')
      slice_min = min.to_i - 1
      slice_min += offset if offset
      result.push(*array.slice(slice_min, max.to_i - min.to_i + 1))
    else
      index = r.to_i - 1
      index += offset if offset
      result.push(array[index])
    end
    end
    return result
  end

end