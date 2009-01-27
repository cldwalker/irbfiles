# from http://github.com/xaviershay/dotfiles/blob/master/irbrc
# where_is_this_defined { some_object.some_method() } => <file>:<line>:
def where_is_this_defined(settings={}, &block)
  settings[:debug] ||= false
  settings[:educated_guess] ||= false
  
  events = []
  
  set_trace_func lambda { |event, file, line, id, binding, classname|
    events << { :event => event, :file => file, :line => line, :id => id, :binding => binding, :classname => classname }
    
    if settings[:debug]
      puts "event => #{event}"
      puts "file => #{file}"
      puts "line => #{line}"
      puts "id => #{id}"
      puts "binding => #{binding}"
      puts "classname => #{classname}"
      puts ''
    end
  }
  yield
  set_trace_func(nil)

  events.each do |event|
    next unless event[:event] == 'call' or (event[:event] == 'return' and event[:classname].included_modules.include?(ActiveRecord::Associations))
    return "#{event[:classname]} received message '#{event[:id]}', Line \##{event[:line]} of #{event[:file]}"
  end
  
  # def self.crazy_custom_finder
  #  return find(:all......)
  # end
  # return unless event == 'call' or (event == 'return' and classname.included_modules.include?(ActiveRecord::Associations))
  # which_file = "Line \##{line} of #{file}"
  if settings[:educated_guess] and events.size > 3
    event = events[-3]
    return "#{event[:classname]} received message '#{event[:id]}', Line \##{event[:line]} of #{event[:file]}"
  end
  
  return 'Unable to determine where method was defined.'
end
