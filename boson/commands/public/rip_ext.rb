module RipExt
  def self.included(mod)
    require 'rip'
    require 'rip/ext/helpers' # from rip-ext plugin
  end

  def self.config
    {:namespace=>'e'}
  end

  # Prints all extensions
  def files
    Dir[Rip.dir+'/**/*/**/*.bundle']
  end

  def packages
    Rip::Ext::Helpers.find_extension_packages.values.flatten.uniq
  end

  # Prints current ruby md5
  def ruby_md5
    Rip.md5 Rip.ruby
  end
end
