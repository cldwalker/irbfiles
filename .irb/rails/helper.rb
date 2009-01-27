#from http://github.com/defunkt/barefootexamples/blob/a4e0158e0bb0bc39121841c787d15bbcfe0a0e27/10railsrc.rb
#explained http://errtheblog.com/posts/41-real-console-helpers

def Object.method_added(method)
  return super unless method == :helper
  (class<<self;self;end).send(:remove_method, :method_added)

  def helper(*helper_names)
    returning $helper_proxy ||= Object.new do |helper|
      helper_names.each { |h| helper.extend "#{h}_helper".classify.constantize }
    end
  end

  helper.instance_variable_set("@controller", ActionController::Integration::Session.new)

  def helper.method_missing(method, *args, &block)
    @controller.send(method, *args, &block) if @controller && method.to_s =~ /_path$|_url$/
  end

  helper :application rescue nil
end 
