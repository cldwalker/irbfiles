#hack: shell_support should be in g/ not shellable/?
require 'g/shell_support'
#require shell_support #alias_update, ask_yes_no
require 'g/array'

def smart_system(*args)
	options = (args[-1].is_a?(Hash)) ? args.pop : {}
	options = {:screen=>false, :print=>false, :return=>nil, :pretend=>false}.alias_update(options)
	command = args[0]
	command = "screen #{command}" if options[:screen]
	puts "command: '#{command}'" if options[:print] or options[:pretend]
	return nil if options[:pretend]
	if options[:return]
		cmd_output = `#{command}`
		if options[:return] == :array
			return_value = cmd_output.split("\n")
		#string (true, normal?) or pager
		else
			return_value = cmd_output

			if options[:return] == :pager && return_value.respond_to?(:|)
				return_value.|()
				return_value = nil
			end
		end
	#return-boolean, output- stdout
	else
		return_value = system(command)
	end

	return_value
end

#menu
	def smart_menu(*args)
		options = (args[-1].is_a?(Hash)) ? args.pop : {}
		options = {:choose=>:many, :menu=>:horizontal,:prompt=>nil, :always_ask=>true, :menu_method=>nil}.alias_update(options)
		options[:always_ask] = true if options[:parse] == :tagged
		return args[0] if ! options[:always_ask] && (! args[0].is_a?(Array) || (args[0].is_a?(Array) && args[0].size <= 1))
		choices = args[0]
		menu_method = "#{options[:menu]}_menu"

		#common beginning
		menu_input = choices
		menu_input = choices.map {|e| e.send(*options[:menu_method]) } if options[:menu_method]
		prompt_string = send(menu_method, menu_input)

		if options[:choose] == :one
			prompt_string += options[:prompt] || "Choose one ($choice/N): "
			answer = prompt(prompt_string)
			output = (answer) ? parse_one_choice_input(answer,choices) : nil
		#many
		else
			prompt_string += options[:prompt] || ( (options[:parse] == :tagged) ? "Choose items and tags ($items:tags/N) ?" :
				"Choose items ($items/N) ?")
			answer = prompt(prompt_string)
			if answer
				if options[:parse] == :tagged
					output = parse_tagged_menu_input(answer, {:items=>choices})
				else
					output = parse_menu_input(answer, choices)
				end
			else
				output = nil
			end
		end
		output
	end

#io
	def prompt(text,default=false)
		print text
		answer = Kernel.gets.strip
		(answer != '') ? answer : default
	end
#format	
	#?: should it go in shell_support or commands/basic
	def horizontal_menu(arr)
		output = ""
		arr.each_with_index { |arg,i|; output += "#{i + 1}: #{arg}  "}
		output += "\n"
	end

	def vertical_menu(arr)
		body = ''
		arr.each_with_index { |arg,i|;  body += "#{i + 1}: #{arg}\n"}
		body
	end
#parse	
	def parse_one_choice_input(input,arr)
		arr[input.to_i - 1]
	end

	def parse_menu_input(input,arr,opt={})
		(input == '*') ? arr : arr.multislice(input)
	end
	def parse_tagged_menu_input(input,opt={})
		input.split(' ').map { |e|
			entry = {}
			subnum ,tags = e.split(/:/)
			tags ||= ''
			entry[:items] = (subnum == '*') ? opt[:items] : opt[:items].multislice(subnum)
			entry[:tags] = tags.split($config[:tag_delimiter] || ',')
			entry
		}
	end
	def sh_quote(s)
		# don't forget to print out quoted text
		#"'" + s.gsub("'") { |i| "'\\''" } + "'"
		"'" + s.gsub("'") { |i| %q{'\''} } + "'"
	end
