module YardLib
  # @options :pretend=>:boolean, :files=>{:type=>:array, :default=>['bin/*', 'lib/**/*.rb'] },
  #  :edits=>:boolean
  # Converts rdoc tags (:nodoc:, :startdoc:, :stopdoc:) to yard's @private
  def convert(options={})
    total_edits = []
    files = Dir.glob(options[:files])
    files.each do |f|
      edits = []
      (lines = IO.readlines(f)).each_with_index {|e,i|
        if e[/#\s*:nodoc:/]
          puts "WARNING: Commented class found" if !e[/^\s*#:nodoc:/] && lines[i-1][/^\s*#/] && e[/^\s*class/]
          after = if !e[/^\s*#:nodoc:/] && lines[i-1][/^(\s*)#/]
            "#{$1}# @private\n" + e.sub(/#\s*:nodoc:/, '')
          else
            e.sub(':nodoc:', '@private')
          end

          edits << [e,after,i]
        end
      }
      body = lines.join("")
      if region = body[/([ \t]*#[ \t]*:stopdoc:\s*\n).*?([ \t]*#[ \t]*:startdoc:\s*\n)/m]
        edits << [$1, '', 'nil']
        startdoc = $2
        region.gsub(/\n\s*def.*?\n/) {|e| edits << [e.sub(/^\s*/,''), e.sub(/^\s*(def.*?)\n/, '\1'+" \#@private\n"), 'nil']; '' }
        edits << [startdoc, '', 'nil']
      end
      if options[:pretend]
        edits.each {|before,after,line|
          puts "Line #{line} of #{f}", before.gsub(/^/, "< "), "---", after.gsub(/^/, "> "), ""
        }
      elsif options[:edits]
        total_edits += edits
      else
        edits.each {|before,after,l| body = body.sub(before, after) }
        File.open(f, 'w') {|f| f.write body }
      end
    end
    options[:edits] ? total_edits : nil
  end
end
