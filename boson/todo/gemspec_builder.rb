# GemspecBuilder builds a Gem::Specification object by looking up a gem's config in the config file ~/.gems.yml.
# GemspecBuilder assumes the current directory's basename is the gem name (unless told otherwise) and needs to be
# run inside the gem's root directory in order for the gemspec to build correctly.
#
# The builder merges the default gemspec hash in config[:default] with any gem-specific configuration in config[:gems][gem_name].
# Gemspec hashes are assumed to have the same attribute-value pairs as Gem::Specification objects (described here:
# http://rubygems.rubyforge.org/rdoc/Gem/Specification.html). The only difference is the :files attribute which takes globbed expressions
# and is converted with Dir.glob.
#
# For an example config see mine: http://github.com/cldwalker/dotfiles/blob/master/.gems.yml
# All config keys are assumed to be symbols.
# Valid config keys are:
# * :default: default gemspec hash with keys being valid Gem::Specification attributes
# * :gems: hash of gem names mapped to their gemspec hashes
class GemspecBuilder
  class <<self
    def build(name_or_hash=nil)
      spec_hash = name_or_hash.is_a?(Hash) ? name_or_hash : gem_config(name_or_hash)
      gemspec = Gem::Specification.new
      spec_hash.each do |k,v|
        if gemspec.respond_to?("#{k}=")
          gemspec.send("#{k}=", v)
        elsif gemspec.respond_to?(k)
          gemspec.send(k, v)
        end
      end
      gemspec.files = Dir[*gemspec.files].uniq
      gemspec
    end

    def gem_config(gem_name=nil)
      gem_name = (gem_name || detect_gem).to_sym
      local_config = config[:gems][gem_name] || {}
      hash = default_config.merge(local_config).merge(:name=>gem_name.to_s)
      post_gem_config(hash)
      hash
    end

    # clone config entry if config value is a symbol i.e. :summary => :description
    def post_gem_config(hash)
      hash.each do |k,v|
        if v.is_a?(Symbol)
          hash[k] = hash[v]
        end
      end
    end

    def default_config
      config[:default] || {}
    end

    def config
      @config ||= YAML::load_file(config_file)
    end

    def config_file
      File.join(ENV['HOME'], '.gems.yml')
    end

    def detect_gem
      File.basename(Dir.pwd)
    end
  end
end
