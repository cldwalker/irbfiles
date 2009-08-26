module KeyMaster
  def keys_used
    render functions_hash.to_a.sort, :headers=>%w{function key}, :filters=>{1=>proc {|e| e.join(",")}}
  end

  def functions_hash
    @functions_hash ||= begin
      hash = IO.readlines(File.expand_path("~/.key_bindings")).select {|e| e =~ /^[^\n#]/ }.
        inject({}) {|h,e| k,v = e.chomp.split(/\s*:\s*/); (h[v] ||= []) << k ; h}
      hash.delete(nil)
      hash
    end
  end

  def bash_functions
    (keys_hash.values.uniq.compact - rline_functions).sort
  end

  def rline_functions
    IO.readlines(File.expand_path("~/.key_bindings_rline")).map {|e| e[/^\S+/]}
  end

  def keys_hash
    @keys_hash ||= begin
      arr = IO.readlines(File.expand_path("~/.key_bindings")).select {|e| e =~ /^[^\n#]/ }.
      inject({}) {|t,e| k,v = e.chomp.split(/\s*:\s*/); t[k] = v; t }
    end
  end
end