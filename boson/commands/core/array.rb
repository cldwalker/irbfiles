module ArrayLib
  # @desc Allows you to specify ranges of elements and individual elements with one string,
  # array starts at 1. Example: choose first and fourth through eighth elements: '1,4-8'
  def multislice(arr, input, options={})
    options = {:splitter=>","}.merge(options)
    return arr if input.strip == '*'
    result = []
    input.split(options[:splitter]).each do |e|
      if e =~ /-|\.\./
        min,max = e.split(/-|\.\./)
        slice_min = min.to_i - 1
        result.push(*arr.slice(slice_min, max.to_i - min.to_i + 1))
      elsif e =~ /\s*(\d+)\s*/
        index = $1.to_i - 1
        next if index < 0
        result.push(arr[index]) if arr[index]
      end
    end
    result
  end

  # @desc Converts an even # of array elements ie [1,2,3,4]
  # or an array of array pairs ie [[1,2],[3,4]] to a hash.
  def to_hash(arr)
    ::Hash[*arr.flatten]
  end

  # Converts an array to a hash mapping a numerical index to its array value.
  def to_indices_hash(arr)
    #::Hash[*(0..arr.length - 1).to_a.zip(arr).flatten]
    arr.inject({}) {|hash,e|  hash[hash.size] = e; hash }
  end

  # Returns hash mapping elements to the number of times they are found in the array
  def count_hash(arr)
    count = {}
    arr.each {|e|
      count[e] ||= 0
      count[e] += 1
    }
    count
  end

  # Returns all possible paired permutations of elements disregarding order
  def permute(arr)
    permutations = []
    for i in (0 .. arr.size - 1)
      for j  in (i + 1 .. arr.size - 1)
        permutations.push([arr[i],arr[j]])
      end
    end
    permutations
  end

  # @desc Assuming the array is an array of hashes, this returns a hash of the elements grouped by their
  # values for the specified hash key. 
  def group_aoh_by_key(arr, key,parallel_array=nil)
    group = {}
    arr.each_with_index {|h,i|
      value = h[key]
      group[value] = [] if ! group.has_key?(value)
      group[value].push((parallel_array.nil?) ? h : parallel_array[i])
    }
    group
  end

  # Maps the result of calling each element with the given instance method and optional arguments.
  def method_map(arr, meth,*args)
    arr.map {|e| e.send(meth,*args) }
  end

  # Maps the result of evaling the method string with each element as its argument.
  def eval_map(arr, meth_string)
    (meth_string =~ /\./) ?  arr.map {|e| eval "#{meth_string}(e)" } :
      arr.map {|e| send(meth_string, e) }
  end

  # Returns index of first element to match given regular expression.
  def regindex(arr, regex)
    arr.each_with_index {|e,i|
      return i if e =~ /#{regex}/
    }
    nil
  end

  # Replaces element at index with values of given array.
  def replace_index!(arr, i,array)
    arr.replace( (arr[0, i] || []) +  array + arr[i + 1 .. -1] )
  end

  # Returns true if it has any elements in common with the given array.
  def include_any?(arr, arr2)
    #good for large sets w/ few matches
    # Set.new(self).intersection(arr).empty?
    arr2.any? {|e| arr.include?(e) }
  end


  # Returns true if it has no elements in common with the given array.
  def exclude_all?(arr, arr2)
    ! include_any?(arr, arr2)
  end

  # @desc A real array def, not a set diff
  # a1 = [1,1,2]
  # a2 = [1,2]
  # a1 - a2 #=> []
  # a1.diff(a2) #=> [1]
  def diff(arr, other)
    new_arr = arr.dup
    other.each { |elem| new_arr.delete_at( new_arr.index(elem) ) }
    new_arr
  end
end