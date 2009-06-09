module RubyRef
  def self.included(mod)
    require 'libraries/hirb'
  end

  def global_variables
    vars = %w{$! $-F $-w $6 $? $VERBOSE $stderr $" $-I $. $7 $@ $\\ $stdin $$ $-K $/ $8 $DEBUG $_ $stdout $& $-a $0 $9 $FILENAME $` $~} +
     %w{$' $-d $1 $: $KCODE $binding $* $-i $2 $; $LOADED_FEATURES $deferr $+ $-l $3 $< $LOAD_PATH $defout $, $-p $4 $= $PROGRAM_NAME} + 
     %w{$fileutils_rb_have_lchmod $-0 $-v $5 $> $SAFE $fileutils_rb_have_lchown}
    table vars.sort.map {|e| [e, (eval e).inspect] }, :max_width=>160, :headers=>{0=>"variable",1=>"value"}
  end
  
  def loaded_paths(reload=false)
    @loaded_paths = get_loaded_paths if reload || @loaded_paths.nil?
    table @loaded_paths.inject([]) {|t,(k,v)| t << {:require_path=>k, :full_path=>v } }.sort_by {|e| e[:require_path]},
      :fields=>[:require_path, :full_path]
  end

  def full_paths
    get_loaded_paths.values
  end

  private
  def get_loaded_paths
    hash = {}
    $".each { |f|
      $:.each { |d|
        test_file = File.join(d, f)
        if test(?e,test_file)
          hash[f] = test_file
          break
        end
      }
    }
    hash
  end
end
