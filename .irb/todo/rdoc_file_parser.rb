#Works with rdoc distributed with ruby 1.8.2
require 'rdoc/rdoc.rb'

## modified rdoc/code_objects.rb
## to index all subs + klasses regardless of nodoc/stopdoc directives
module RDoc
  class CodeObject
    def stop_doc
      @document_self = true
      @document_children = true
    end
  end

  class RubyParser
    alias_method :orig_read_documentation_modifiers, :read_documentation_modifiers
    def read_documentation_modifiers(context,allow)
	    orig_read_documentation_modifiers(context,allow)
	    context.document_self = true
	    context.document_children = true
    end
  end
end


#to avoid issues in rdoc/parsers/parse_rb.rb
Options.instance.instance_eval "@tab_width = 8"

def index_class(cls,hash)
	class_name = cls.full_name
	hash[class_name] = cls.method_list.map {|x| x.name } if ! hash[class_name]
	#indexes subclasses of a class
	cls.each_classmodule { |x| index_class(x,hash) }
end

# Correctly parses methods with explicit classes. 
# Todo: Doesn't correctly parse global methods, methods without a class.
def rdoc_parse_file(file)
	class_hash = {}
	RDoc::TopLevel::reset
	content = File.open(file, "r") {|f| f.read}
	capital_p = RDoc::ParserFactory.parser_for(RDoc::TopLevel.new(file),file,content,Options.instance,RDoc::Stats.new)
	capital_p.scan
	rclasses = RDoc::TopLevel.all_classes_and_modules
	rclasses.each {|rc| index_class(rc,class_hash) }
	class_hash
end

__END__
#P = RDoc::RubyParser.new(RDoc::TopLevel.new(file),file,content,Options.instance,RDoc::Stats.new)
#
#require 'rdoc/options.rb'
#require 'rdoc/code_objects.rb'
#require 'rdoc/parsers/parse_rb.rb'

#redefined this subroutine cause the commented out section was throwing a bizarre '*' not defined error
#class RubyLex
#class BufferedReader
	#def initialize(content)
		#if /\t/ =~ content
		#tab_width = Options.instance.tab_width
		#content = content.split(/\n/).map do |line|
		#  1 while line.gsub!(/\t+/) { ' ' * (tab_width*$&.length -   $`.length % tab_width)}  && $~ #`
		#    line
		#  end .join("\n")
		#end
		#@content   = content
		#@content << "\n" unless @content[-1,1] == "\n"
		#@size      = @content.size
		#@offset    = 0
		#@hwm       = 0
		#@line_num  = 1
		#@read_back_offset = 0
		#@last_newline = 0
		#@newline_pending = false
	#end
#end
#end

