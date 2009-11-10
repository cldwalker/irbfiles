module HashLib
  # @desc Returns a hash which will set its values by calling each value with the given method and
  # optional argument. If a block is passed, each value will be set the value returned by its block call.
  def vmap(hash, arg=nil,method='[]',&block)
    new_hash = {}
    if block
      hash.each {|k,v|
        v1 = yield(k,v)
        new_hash[k] = v1
      }
    else  
      hash.each {|k,v|
        new_hash[k] = arg.nil? ? v.send(method) : v.send(method,arg)
      }
    end
    new_hash
  end
  
  # Same as vmap() but merges its results with the existing hash.
  def vmap!(*args,&block)
    args.shift.update(vmap(*args,&block))
  end

  # @desc For a hash whose values are arrays, this will return a hash with each value substituted
  # by the size of the value.
  def vsize(hash)
    vmap(hash, nil,'size')
  end

  # Only keeps the given keys of the hash. Like Rails' slice().
  def only_keep!(hash, keys)
    delete_keys!(hash, hash.keys - keys)
  end

  # Deletes given keys from hash, returning the deleted hash. Like Rails' except().
  def delete_keys!(hash, keys)
    deleted = {}
    keys.each {|e| 
      deleted[e] = hash.delete(e) if hash.key?(e)
    }
    deleted
  end
  
  # @desc For a hash whose values are arrays, this will set each unique element in a value array as a key
  # and set its values to all the keys it occurred in. This is useful when modeling one to many relationships
  # with keys and values.
  def transform_many(hash)
    b = {}
    hash.each {|k,arr|
      Array(arr).each {|e| 
        b.key?(e) ? b[e].push(k) : b[e] = [k]
      }
    }
    b
  end

  #Sorts hash by values, returning them as an array of array pairs.
  def vsort(hash)
    hash.sort { |a,b| b[1]<=>a[1] }
  end

  # Recursively merge two hash
  def recursive_merge(hash, hash2)
    hash.merge(hash2) {|k,o,n| (o.is_a?(Hash)) ? recursive_hash_merge(o,n) : n}
  end

  # Deletes exact key-value pair or a key from a hash.
  def minus(hash, hash_or_key)
    if hash_or_key.is_a? Hash
      hash_or_key.each do |key, value|
        hash.delete(key) if hash[key] == value
      end
    elsif hash.keys.include? hash_or_key
      hash.delete(hash_or_key)
    end
    hash
  end
end