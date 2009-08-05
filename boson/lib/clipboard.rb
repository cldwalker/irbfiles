# original clipboard code: http://project.ioni.st/post/1334#snippet_1334
# turned it into a class to make it flexxy:
# http://gilesbowkett.blogspot.com/2007/09/improved-auto-pastie-irb-code.html
# Extended to handle windows and linux as well
# copied from http://github.com/akitaonrails/utility-belt/blob/bdf51947645a44cb96ed00cc5dcb18a62a07ccc0/lib/utility_belt/clipboard.rb
require 'platform'

class Clipboard
  
  def self.available?
    @@implemented || false
  end
  
  case Platform::IMPL
  when :macosx

    def self.read
      IO.popen('pbpaste') {|clipboard| clipboard.read}
    end

    def self.write(stuff)
      IO.popen('pbcopy', 'w+') {|clipboard| clipboard.write(stuff)}
    end
    @@implemented = true

  when :mswin

    begin
      # Try loading the win32-clipboard gem
      require 'win32/clipboard'

      def self.read
        Win32::Clipboard.data
      end

      def self.write(stuff)
        Win32::Clipboard.set_data(stuff)
      end
      @@implemented = true

    rescue LoadError
      raise "You need the win32-clipboard gem for clipboard functionality!"
    end

  when :linux
    #test execute xsel
    `xsel`
    if $?.exitstatus != 0
      raise "You need to install xsel for clipboard functionality!"
    end

    def self.read
      `xsel`
    end
    
    def self.write(stuff)
      `echo '#{stuff}' | xsel -i`
    end
    @@implemented = true

  else
    raise "No suitable clipboard implementation for your platform found!"
  end
end