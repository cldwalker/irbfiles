module GemRelease
  def self.config
    {:dependencies=>['public/rake', 'personal/gh_pages/main']}
  end

  def release
    rake('release')
    rake('rubyforge:release:gem')
    rdoc
    publish
  end
end