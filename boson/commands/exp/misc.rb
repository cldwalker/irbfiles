module Misc
  # Hash of class dependencies excluding error-related ones
  def dependencies
    deps = {}
    ObjectSpace.each_object Class do |mod|
      next if mod.name =~ /Errno/
      next if mod < Exception
      deps[mod.to_s] = mod.superclass.to_s
    end
    # dependencies.inject({}) {|h,(k,v)| (h[v] ||= []) << k; h }
    deps
  end

  # Explained http://tagaholic.blogspot.com/2009/01/simple-block-to-hash-conversion-for.html
  # Converts a block definition into a hash
  def block_to_hash(block=nil)
    require 'open_struct'
    config = OpenStruct.new
    if block
      block.call(config)
      config.instance_variable_get("@table")
    else
      {}
    end
  end

  # from http://stackoverflow.com/questions/1744424/handling-data-structures-hashes-etc-gracefully-in-ruby
  # Iterates over a nested data structure and stops to yield at a non-array/non-hash elements
  def iterate_nested(array_or_hash, depth = [], &block)
    case array_or_hash
      when Array:
        array_or_hash.each_with_index do |item, key|
          if item.class == Array || item.class == Hash
            iterate_nested(item, depth + [key], &block)
          else
            block.call(key, item, depth + [key])
          end
        end
      when Hash:
        array_or_hash.each do |key, item|
          if item.class == Array || item.class == Hash
            iterate_nested(item, depth + [key], &block)
          else
            block.call(key, item, depth + [key])
          end
        end
    end
  end
end