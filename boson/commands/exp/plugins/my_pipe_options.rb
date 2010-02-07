module MyPipeOptions
  def self.after_included
    ::Boson::OptionCommand::PIPE_OPTIONS[:pipes].merge! :enum=>false, :values=>%w{pastie_string gist_string}
    ::Boson::Pipe.add_pipes :command=>{
      :alias=>'C', :type=>:array, :desc=>"Pipe to commands sequentially", :filter=>true, :pipe=>:post_command},
      :key_slice=>{:type=>:hash, :filter=>true, :no_render=>true, :solo=>true},
      :eval=>{:type=>:string, :filter=>true, :pipe=>:eval_pipe, :no_render=>true, :desc=>"instance eval"}
  end

  def eval_pipe(obj, eval_string)
    eval_string = (eval_string[/^\[/] ? 'self' : 'self.') + eval_string
    obj.instance_eval(eval_string)
  end

  # Pipe command to pipe commands in sequence
  def post_command(arg, arr)
    arr.inject(arg) {|acc,e| Boson.full_invoke(e, [acc]) }
  end

  # @desc Pipe command to slice an array of hashes by a key and executes a command on the resulting array.
  # Hash should be command/key pairs
  def key_slice(input, hash)
    return "Must be an array of hashes" unless input.is_a?(Array) && input[0].is_a?(Hash)
    fields = input[0].keys.sort_by {|e| e.to_s }
    hash.inject(input) {|acc,(cmd, field)|
      field = Boson::Util.underscore_search(field, fields, true) || field
      acc = acc.map {|e| e[field] }
      Boson.full_invoke(cmd, [acc])
    }
  end
end