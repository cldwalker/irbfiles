module Git
  def self.included(mod)
    require 'grit'
  end

  # @render_options :change_fields=>['repo', 'pending'], :sort=>'pending',
  #  :reverse_sort=>true
  # Lists # of commits that haven't been pushed to origin/master
  def pending_commits
    Git.repos.map{|e|
      [File.basename(e.working_dir), e.log('origin/master..master').size]
    }
  end

  # List repo's latest commits
  def repo_commits(repo)
    Git.repo_hash[repo].commits
  end

  # @render_options :change_fields=>['repo', 'changed', 'added', 'deleted'], :sort=>'changed',
  #  :reverse_sort=>true
  # List status of repos
  def repo_stati
    Git.repos.map {|e|
      status = e.status
      [File.basename(e.working_dir), status.changed.size, status.added.size, status.deleted.size]
    }
  end

  # Push given repos to origin/master
  def push_repos(*repos)
    repos.each do |e|
      Git.repo_hash[e].git.push
    end
  end

  # Hash to access repo objects
  def repos
    Git.repo_hash
  end

  # @render_options :change_fields=>['repo', 'date'], :sort=>'date', :reverse_sort=>true
  # Lists last commit of each repo
  def last_commits
    Git.repos.map {|e|
      [File.basename(e.working_dir), e.commits[0].committed_date]
    }
  end

  class<<self
    def repo_hash
      @repo_hash ||= begin
        dirs.inject({}) {|a,e| a[File.basename(e)] = Grit::Repo.new(e); a }
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
