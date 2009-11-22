module Git
  def self.included(mod)
    require 'grit'
  end

  # @render_options :change_fields=>['repo', 'date']
  def last_commits
    Git.repos.map {|e|
      [File.basename(e.working_dir), e.commits[0].committed_date]
    }
  end

  class<<self
    def repo_hash
      @repo_hash ||= begin
        dirs.inject({}) {|a,e| a[e] = Grit::Repo.new(e); a }
      end
    end

    def repos
      repo_hash.values
    end

    def dirs
      Dir.glob('/home/bozo/code/{gems,repo}/*/.git').map {|e| e.gsub('/.git','') }
    end
  end
end