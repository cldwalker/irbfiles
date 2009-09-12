# Similar to utility_belt's command history
# Prints, evals and edits history by specifying start and end history numbers.
# For example, 1-3,7 specifies lines 1 through 3 and line 7. Default is all lines.
# consider copy history like http://pastie.org/501623
module History
  class<<self; attr_accessor :original_history_size ; end
  
  def self.included(mod)
    require 'readline'
    if Object.const_defined?(:IRB_PROCS)
      IRB_PROCS[:set_command_history] = lambda { self.original_history_size =  Readline::HISTORY.size }
    else
      self.original_history_size = Readline::HISTORY.size
    end
  end

  # options :return_array=>:boolean, :edit=>:boolean, ["--eval", "-x"]=>:boolean
  # Print, eval, edit console history specified by slice arguments or multislice string
  def history(*args)
    options = args[-1].is_a?(Hash) ? args.pop : {}
    list = history_list_or_slice(*args)
    list = edit_string list.join("\n") if options[:edit]
    console_eval(list.is_a?(Array) ? list.join("\n") : list) if options[:eval]
    if options[:return_array] || list.is_a?(String)
      list
    else
      render list.compact, :number=>true
    end
  end

  def edit_string(string=nil,editor=ENV['EDITOR'])
    require 'tempfile'
    editor ||= raise "editor must be given or defined by EDITOR environment variable"
    tempfile = Tempfile.new('edit_string')
    File.open(tempfile.path,'w') {|f| f.write(string) } if string
    system(editor, tempfile.path)
    File.open(tempfile.path) {|f| f.read } 
  end

  private
  def history_list(start_num=1,end_num=Readline::HISTORY.size - 1)
    Readline::HISTORY.to_a[(start_num + original_history_size - 1) .. (end_num + original_history_size - 1) ]
  end

  def original_history_size
    History.original_history_size
  end

  def history_list_or_slice(*args)
    if args[0].class == String
      multislice(Readline::HISTORY.to_a, args[0],',', original_history_size)
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