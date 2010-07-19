module Git
  def self.included(mod)
    require 'grit'
  end

  # @render_options :change_fields=>['repo', 'pending'], :sort=>'pending',
  #  :reverse_sort=>true
  # @options :push=>:boolean, :repo=>{:type=>:string, :values=>%w{all gems menu}, :enum=>false}
  # Lists # of commits that haven't been pushed to origin/master
  def pending_commits(options={})
    pending = Git.repos(options).map{|e|
      [e.working_dir, e.log('origin/master..master').size]
    }
    if options[:push] 
      pending.select {|k,v| v > 0 }.each {|k,v|
        Dir.chdir k
        system "git push origin master"
        puts "Pushed '#{File.basename(k)}'"
      }
    else
      pending.map {|k,v| [File.basename(k), v] }
    end
  end

  # List repo's latest commits
  def repo_commits(repo)
    Git.repo_hash[repo].commits
  end

  # @render_options :change_fields=>['repo', 'changed', 'added', 'deleted'], :sort=>'changed',
  #  :reverse_sort=>true
  # @options :repo=>{:type=>:string, :values=>%w{all gems menu}, :enum=>false}
  # List status of repos. Buggy grit results
  def buggy_repo_stati(options={})
    Git.repos(options).map {|e|
      status = e.status
      [File.basename(e.working_dir), status.changed.size, status.added.size, status.deleted.size]
    }
  end

  # @options :repo=>{:type=>:string, :values=>%w{all gems menu}, :enum=>false}, :expand=>:boolean
  # List status of repos
  def repo_stati(options={})
    Git.dirs(options).map {|e|
      Dir.chdir e
      status = `git status -s`.split("\n")
      status = status.size unless options[:expand]
      [File.basename(e), status]
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
    def repo_hash(options={})
      @repo_hash ||= begin
        dirs(options).inject({}) {|a,e| a[File.basename(e)] = Grit::Repo.new(e); a }
      end
    end

    def repos(options={})
      repo_hash(options).values
    end

    def dirs(options={})
      @options = {:repo=>'all'}.merge options
      repo_dirs = %w{all menu}.include?(@options[:repo]) ? 'gems,repo' : @options[:repo]
      repo_dirs = Dir[File.expand_path("~/code/{#{repo_dirs}}/*/.git")].map {|e| e.gsub('/.git','') }
      repo_dirs = Boson.invoke(:menu, repo_dirs) if @options[:repo] == 'menu'
      repo_dirs
    end
  end
end
